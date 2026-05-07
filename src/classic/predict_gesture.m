function label = predict_gesture(img, model)
    feature = extract_features(img);
    feature = (feature - model.mu) ./ model.sigma;
    label = knn_predict(feature, model.trainFeatures, model.trainLabels, model.classes, model.k);
    label = label{1};
end
