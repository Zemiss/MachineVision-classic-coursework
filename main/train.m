function train(varargin)
clc;

scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(scriptDir, 'src')));

paths = load_project_config(scriptDir);
[datasetFolder, modelPath] = parse_train_args(varargin, paths.dataFolder, paths.modelPath);

classes = {'A', 'C', 'Five', 'V'};
k = 4;
numRepeats = 5;
numFolds = 10;
baseSeed = 42;


classImageFiles = cell(numel(classes), 1);
numImages = 0;

for c = 1:numel(classes)
    className = classes{c};
    classImageFiles{c} = dir(fullfile(datasetFolder, className, '*.png'));
    numImages = numImages + numel(classImageFiles{c});
end

imagePaths = cell(numImages, 1);
labels = cell(numImages, 1);
imageNames = cell(numImages, 1);
row = 1;

for c = 1:numel(classes)
    className = classes{c};
    imageFiles = classImageFiles{c};
    for i = 1:numel(imageFiles)
        imagePaths{row} = fullfile(imageFiles(i).folder, imageFiles(i).name);
        labels{row} = className;
        imageNames{row} = imageFiles(i).name;
        row = row + 1;
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

modelDir = fileparts(modelPath);
if ~isempty(modelDir) && ~exist(modelDir, 'dir')
    mkdir(modelDir);
end
save(modelPath, 'model');

fprintf('Training images: %d\n', numel(labels));
fprintf('Validation accuracy (mean %s): %.2f%%\n', model.validationProtocol, accuracy * 100);
fprintf('Confusion matrix rows=actual, columns=predicted:\n');
disp(array2table(confusionMatrix, 'VariableNames', classes, 'RowNames', classes));
fprintf('Model saved to: %s\n', modelPath);
end

function [datasetFolder, modelPath] = parse_train_args(args, defaultData, defaultOutput)
    datasetFolder = defaultData;
    modelPath = defaultOutput;

    if mod(numel(args), 2) ~= 0
        error('Arguments must be name-value pairs, for example: train(''-data'', ''C:/data'', ''-out'', ''C:/model.mat'')');
    end

    for i = 1:2:numel(args)
        name = char(string(args{i}));
        value = char(string(args{i + 1}));

        switch lower(name)
            case {'-data', 'data'}
                datasetFolder = value;
            case {'-out', 'out', '-output', 'output'}
                modelPath = value;
            otherwise
                error('Unknown argument: %s. Supported arguments: -data, -out', name);
        end
    end
end

function paths = load_project_config(mainDir)
    % Load project paths from YAML config file
    configFile = fullfile(mainDir, 'configs', 'default.yaml');

    if ~exist(configFile, 'file')
        error('Config file not found: %s', configFile);
    end

    % Simple YAML parser for project_config.yaml
    fid = fopen(configFile, 'r');
    content = fread(fid, '*char')';
    fclose(fid);

    paths = struct();

    % Parse data_folder
    match = regexp(content, 'data_folder:\s*"([^"]+)"', 'tokens');
    if ~isempty(match)
        paths.dataFolder = fullfile(mainDir, match{1}{1});
    else
        error('Failed to parse data_folder from config');
    end

    % Parse test_folder
    match = regexp(content, 'test_folder:\s*"([^"]+)"', 'tokens');
    if ~isempty(match)
        paths.testFolder = fullfile(mainDir, match{1}{1});
    else
        error('Failed to parse test_folder from config');
    end

    % Parse model_path
    match = regexp(content, 'model_path:\s*"([^"]+)"', 'tokens');
    if ~isempty(match)
        paths.modelPath = fullfile(mainDir, match{1}{1});
    else
        error('Failed to parse model_path from config');
    end
end
