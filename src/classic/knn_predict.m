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
