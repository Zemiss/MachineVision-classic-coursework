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

    smallGray = imresize(gray, [16, 16]);
    grayFeature = smallGray(:)';

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

    rowProjection = sum(mask, 2)' / size(mask, 2);
    colProjection = sum(mask, 1) / size(mask, 1);
    rowProjection = imresize(rowProjection, [1, 16]);
    colProjection = imresize(colProjection, [1, 16]);

    feature = double([grayFeature, geometry, rowProjection, colProjection]);
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
