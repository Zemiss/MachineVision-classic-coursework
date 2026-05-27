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
