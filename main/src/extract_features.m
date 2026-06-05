function feature = extract_features(img)
    data = preprocess_image(img);
    gray = data.gray;
    mask = data.mask;

    if any(mask(:))
        [rows, cols] = find(mask);
        rowStart = max(min(rows) - 2, 1);
        rowEnd = min(max(rows) + 2, size(mask, 1));
        colStart = max(min(cols) - 2, 1);
        colEnd = min(max(cols) + 2, size(mask, 2));
        gray = gray(rowStart:rowEnd, colStart:colEnd);
        mask = mask(rowStart:rowEnd, colStart:colEnd);
    end

    gray = pad_to_square(gray, mean(gray(:)));
    mask = pad_to_square(double(mask), 0) > 0.5;

    gray64 = imresize(gray, [64, 64]);
    mask64 = imresize(double(mask), [64, 64]) > 0.5;

    hogGray = extractHOGFeatures(gray64, 'CellSize', [16, 16]);
    hogMask = extractHOGFeatures(double(mask64), 'CellSize', [16, 16]);
    lbpGray = extract_lbp_grid_histogram(gray64, 4, 4, 16);
    lbpMask = extract_lbp_grid_histogram(double(mask64), 4, 4, 16);

    [rows, cols] = find(mask);
    if isempty(rows)
        geometry = zeros(1, 8);
    else
        area = sum(mask(:)) / numel(mask);
        height = (max(rows) - min(rows) + 1) / size(mask, 1);
        width = (max(cols) - min(cols) + 1) / size(mask, 2);
        aspect = width / max(height, eps);
        centroidRow = mean(rows) / size(mask, 1);
        centroidCol = mean(cols) / size(mask, 2);
        perimeter = estimate_perimeter(mask) / numel(mask);
        compactness = perimeter^2 / max(area, eps);
        geometry = [area, width, height, aspect, centroidRow, centroidCol, perimeter, compactness];
    end

    feature = double([hogGray, hogMask, lbpGray, lbpMask, geometry]);
end

function feature = extract_lbp_grid_histogram(img, gridRows, gridCols, numBins)
    img = double(img);
    if max(img(:)) > 1
        img = img / 255;
    end

    padded = padarray(img, [1, 1], 'replicate');
    center = padded(2:end-1, 2:end-1);
    codes = zeros(size(img));

    offsets = [
        -1, -1
        -1,  0
        -1,  1
         0,  1
         1,  1
         1,  0
         1, -1
         0, -1
    ];

    for k = 1:size(offsets, 1)
        neighbor = padded(2 + offsets(k, 1):end-1 + offsets(k, 1), ...
                          2 + offsets(k, 2):end-1 + offsets(k, 2));
        codes = codes + double(neighbor >= center) * 2^(k - 1);
    end

    binIds = min(floor(codes / (256 / numBins)) + 1, numBins);
    rowEdges = round(linspace(1, size(img, 1) + 1, gridRows + 1));
    colEdges = round(linspace(1, size(img, 2) + 1, gridCols + 1));
    feature = zeros(1, gridRows * gridCols * numBins);
    pos = 1;

    for r = 1:gridRows
        for c = 1:gridCols
            cellBins = binIds(rowEdges(r):rowEdges(r + 1) - 1, ...
                              colEdges(c):colEdges(c + 1) - 1);
            histValues = zeros(1, numBins);
            for b = 1:numBins
                histValues(b) = sum(cellBins(:) == b);
            end
            histValues = histValues / max(sum(histValues), eps);
            feature(pos:pos + numBins - 1) = histValues;
            pos = pos + numBins;
        end
    end
end

function perimeter = estimate_perimeter(mask)
    padded = padarray(mask, [1, 1], false);
    center = padded(2:end-1, 2:end-1);
    up = padded(1:end-2, 2:end-1);
    down = padded(3:end, 2:end-1);
    left = padded(2:end-1, 1:end-2);
    right = padded(2:end-1, 3:end);
    edge = center & (~up | ~down | ~left | ~right);
    perimeter = sum(edge(:));
end

function square = pad_to_square(img, fillValue)
    [h, w] = size(img);
    side = max(h, w);

    padTop = floor((side - h) / 2);
    padBottom = side - h - padTop;
    padLeft = floor((side - w) / 2);
    padRight = side - w - padLeft;

    square = padarray(img, [padTop, padLeft], fillValue, 'pre');
    square = padarray(square, [padBottom, padRight], fillValue, 'post');
end

function data = preprocess_image(img)
    if ndims(img) == 3
        img = 0.2989 * double(img(:, :, 1)) + ...
              0.5870 * double(img(:, :, 2)) + ...
              0.1140 * double(img(:, :, 3));
    else
        img = double(img);
    end

    if max(img(:)) > 1
        gray = img / 255;
    else
        gray = img;
    end

    resizedGray = imresize(gray, [64, 64]);
    threshold = otsu_threshold(resizedGray);
    darkMask = resizedGray < threshold;
    lightMask = resizedGray > threshold;

    if sum(lightMask(:)) < sum(darkMask(:))
        mask = lightMask;
    else
        mask = darkMask;
    end

    mask = keep_largest_component(mask);
    data.gray = resizedGray;
    data.mask = mask;
end

function threshold = otsu_threshold(gray)
    values = min(max(gray(:), 0), 1);
    counts = histcounts(values, 0:1/256:1);
    p = counts / max(sum(counts), 1);
    omega = cumsum(p);
    mu = cumsum(p .* (1:256));
    muTotal = mu(end);
    sigmaB = (muTotal * omega - mu).^2 ./ max(omega .* (1 - omega), eps);
    [~, idx] = max(sigmaB);
    threshold = (idx - 1) / 255;
end

function largest = keep_largest_component(mask)
    visited = false(size(mask));
    largest = false(size(mask));
    bestCount = 0;

    for r = 1:size(mask, 1)
        for c = 1:size(mask, 2)
            if mask(r, c) && ~visited(r, c)
                component = false(size(mask));
                queue = zeros(numel(mask), 2);
                head = 1;
                tail = 1;
                queue(tail, :) = [r, c];
                visited(r, c) = true;
                count = 0;

                while head <= tail
                    pos = queue(head, :);
                    head = head + 1;
                    rr = pos(1);
                    cc = pos(2);
                    component(rr, cc) = true;
                    count = count + 1;

                    for dr = -1:1
                        for dc = -1:1
                            if abs(dr) + abs(dc) ~= 1
                                continue;
                            end
                            nr = rr + dr;
                            nc = cc + dc;
                            if nr >= 1 && nr <= size(mask, 1) && nc >= 1 && nc <= size(mask, 2) && ...
                                    mask(nr, nc) && ~visited(nr, nc)
                                tail = tail + 1;
                                queue(tail, :) = [nr, nc];
                                visited(nr, nc) = true;
                            end
                        end
                    end
                end

                if count > bestCount
                    bestCount = count;
                    largest = component;
                end
            end
        end
    end

    if bestCount == 0
        largest = mask;
    end
end
