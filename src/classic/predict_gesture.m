function label = predict_gesture(img, model)
    feature = extract_features(img);
    feature = (feature - model.mu) ./ model.sigma;
    if isfield(model, 'classifier') && ~isempty(model.classifier)
        predicted = predict(model.classifier, feature);
        label = char(string(predicted));
    else
        label = knn_predict(feature, model.trainFeatures, model.trainLabels, model.classes, model.k);
        label = label{1};
    end
end
