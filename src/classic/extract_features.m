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
