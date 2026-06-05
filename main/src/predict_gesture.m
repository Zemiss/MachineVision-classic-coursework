function label = predict_gesture(img, model)
    feature = extract_features(img);
    if isfield(model, 'mu') && numel(model.mu) ~= numel(feature)
        error('Model feature dimension (%d) does not match extract_features output (%d). Re-run scripts/train.m.', ...
            numel(model.mu), numel(feature));
    end
    feature = (feature - model.mu) ./ model.sigma;
    if isfield(model, 'classifier') && ~isempty(model.classifier)
        predicted = predict(model.classifier, feature);
        label = char(string(predicted));
    else
        label = knn_predict(feature, model.trainFeatures, model.trainLabels, model.classes, model.k);
        label = label{1};
    end
end

function predicted = knn_predict(testFeatures, trainFeatures, trainLabels, classes, k)
    predicted = cell(size(testFeatures, 1), 1);
    k = min(k, size(trainFeatures, 1));

    for i = 1:size(testFeatures, 1)
        distances = sum((trainFeatures - testFeatures(i, :)).^2, 2);
        [~, order] = sort(distances, 'ascend');
        neighbors = trainLabels(order(1:k));
        predicted{i} = vote_label(neighbors, classes);
    end
end

function label = vote_label(neighbors, classes)
    counts = zeros(numel(classes), 1);
    for i = 1:numel(classes)
        counts(i) = sum(strcmp(neighbors, classes{i}));
    end
    [~, best] = max(counts);
    label = classes{best};
end
