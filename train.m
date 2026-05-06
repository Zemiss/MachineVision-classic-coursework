clearvars -except datasetFolder; clc;

if ~exist('datasetFolder', 'var') || isempty(datasetFolder)
    datasetFolder = fullfile(pwd, 'data', 'Hand_Posture_Easy_Stu');
end

classes = {'A', 'C', 'Five', 'V'};
k = 3;
rng(42);

imagePaths = {};
labels = {};
imageNames = {};

for c = 1:numel(classes)
    className = classes{c};
    imageFiles = dir(fullfile(datasetFolder, className, '*.png'));
    for i = 1:numel(imageFiles)
        imagePaths{end + 1, 1} = fullfile(imageFiles(i).folder, imageFiles(i).name); %#ok<SAGROW>
        labels{end + 1, 1} = className; %#ok<SAGROW>
        imageNames{end + 1, 1} = imageFiles(i).name; %#ok<SAGROW>
    end
end

if isempty(imagePaths)
    error('No PNG images found under %s', datasetFolder);
end

firstFeature = extract_features(imread(imagePaths{1}));
features = zeros(numel(imagePaths), numel(firstFeature));
features(1, :) = firstFeature;
for i = 2:numel(imagePaths)
    features(i, :) = extract_features(imread(imagePaths{i}));
end

trainIdx = false(numel(labels), 1);
testIdx = false(numel(labels), 1);
for c = 1:numel(classes)
    idx = find(strcmp(labels, classes{c}));
    idx = idx(randperm(numel(idx)));
    nTrain = max(1, round(0.8 * numel(idx)));
    trainIdx(idx(1:nTrain)) = true;
    testIdx(idx(nTrain + 1:end)) = true;
end

[splitTrainFeatures, splitMu, splitSigma] = normalize_features(features(trainIdx, :));
splitTestFeatures = (features(testIdx, :) - splitMu) ./ splitSigma;
predicted = knn_predict(splitTestFeatures, splitTrainFeatures, labels(trainIdx), classes, k);

testLabels = labels(testIdx);
accuracy = mean(strcmp(predicted, testLabels));
confusionMatrix = zeros(numel(classes));
for i = 1:numel(testLabels)
    actualId = find(strcmp(classes, testLabels{i}));
    predictedId = find(strcmp(classes, predicted{i}));
    confusionMatrix(actualId, predictedId) = confusionMatrix(actualId, predictedId) + 1;
end

[trainFeatures, mu, sigma] = normalize_features(features);
model = struct();
model.classes = classes;
model.trainFeatures = trainFeatures;
model.trainLabels = labels;
model.mu = mu;
model.sigma = sigma;
model.k = k;
model.imageSize = [64, 64];
model.featureDescription = '64x64 grayscale downsample + binary mask geometry + projection features; KNN classifier';
model.validationAccuracy = accuracy;
model.confusionMatrix = confusionMatrix;
model.validationClasses = classes;
model.datasetFolder = datasetFolder;
model.imageNames = imageNames;

save('gesture_model.mat', 'model');

fprintf('Training images: %d\n', numel(labels));
fprintf('Hold-out accuracy: %.2f%%\n', accuracy * 100);
fprintf('Confusion matrix rows=actual, columns=predicted:\n');
disp(array2table(confusionMatrix, 'VariableNames', classes, 'RowNames', classes));
