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
