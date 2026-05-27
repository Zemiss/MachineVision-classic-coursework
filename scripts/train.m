clearvars -except datasetFolder; clc;

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));

if ~exist('datasetFolder', 'var') || isempty(datasetFolder)
    datasetFolder = fullfile(projectRoot, 'data', 'Hand_Posture_Easy_Stu');
end

classes = {'A', 'C', 'Five', 'V'};
k = 4;
numRepeats = 5;
numFolds = 10;
baseSeed = 42;


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

labelsCat = categorical(labels, classes);
template = templateSVM( ...
    'KernelFunction', 'rbf', ...
    'KernelScale', 'auto', ...
    'BoxConstraint', 5, ...
    'Standardize', false);

repeatAcc = zeros(numRepeats, 1);
confusionMatrix = zeros(numel(classes), numel(classes));

for rep = 1:numRepeats
    rng(baseSeed + rep);
    cv = cvpartition(labelsCat, 'KFold', numFolds);
    repeatPredicted = cell(numel(labels), 1);

    for fold = 1:cv.NumTestSets
        trainMask = training(cv, fold);
        testMask = test(cv, fold);

        [splitTrainFeatures, splitMu, splitSigma] = normalize_features(features(trainMask, :));
        splitTestFeatures = (features(testMask, :) - splitMu) ./ splitSigma;
        foldModel = fitcecoc(splitTrainFeatures, labelsCat(trainMask), ...
            'Coding', 'onevsall', 'Learners', template);

        foldPredicted = cellstr(string(predict(foldModel, splitTestFeatures)));
        repeatPredicted(testMask) = foldPredicted;
    end

    repeatAcc(rep) = mean(strcmp(repeatPredicted, labels));

    if rep == 1
        for i = 1:numel(labels)
            actualId = find(strcmp(classes, labels{i}));
            predictedId = find(strcmp(classes, repeatPredicted{i}));
            confusionMatrix(actualId, predictedId) = confusionMatrix(actualId, predictedId) + 1;
        end
    end
end

accuracy = mean(repeatAcc);

[trainFeatures, mu, sigma] = normalize_features(features);
classifier = fitcecoc(trainFeatures, labelsCat, 'Coding', 'onevsall', 'Learners', template);

model = struct();
model.classes = classes;
model.trainFeatures = trainFeatures;
model.trainLabels = labels;
model.mu = mu;
model.sigma = sigma;
model.k = k;
model.classifier = classifier;
model.imageSize = [64, 64];
model.featureDescription = 'Square-padded grayscale HOG + binary mask HOG + 4x4 LBP grid histograms + geometry features; RBF SVM ECOC classifier';
model.featureLength = size(trainFeatures, 2);
model.validationAccuracy = accuracy;
model.confusionMatrix = confusionMatrix;
model.validationClasses = classes;
model.datasetFolder = datasetFolder;
model.imageNames = imageNames;
model.validationProtocol = sprintf('%d-repeat %d-fold cross-validation', numRepeats, numFolds);

modelDir = fullfile(projectRoot, 'models');
if ~exist(modelDir, 'dir')
    mkdir(modelDir);
end
save(fullfile(modelDir, 'gesture_model.mat'), 'model');

fprintf('Training images: %d\n', numel(labels));
fprintf('Validation accuracy (mean %s): %.2f%%\n', model.validationProtocol, accuracy * 100);
fprintf('Confusion matrix rows=actual, columns=predicted:\n');
disp(array2table(confusionMatrix, 'VariableNames', classes, 'RowNames', classes));
