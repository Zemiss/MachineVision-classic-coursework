clear; clc;

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));

requiredFiles = {
    fullfile('scripts', 'train.m')
    fullfile('scripts', 'evaluate.m')
    fullfile('scripts', 'startup_check.m')
    'preprocess_image.m'
    'extract_features.m'
    'normalize_features.m'
    'knn_predict.m'
    'predict_gesture.m'
    fullfile('models', 'gesture_model.mat')
};

fprintf('Checking MATLAB environment...\n');
fprintf('MATLAB version: %s\n', version);

assert(exist('imresize', 'file') == 2, ...
    'Missing imresize. Please install Image Processing Toolbox.');
assert(exist('padarray', 'file') == 2, ...
    'Missing padarray. Please install Image Processing Toolbox.');
assert(exist('extractHOGFeatures', 'file') == 2, ...
    'Missing extractHOGFeatures. Please install Computer Vision Toolbox.');
assert(exist('templateSVM', 'file') == 2, ...
    'Missing templateSVM. Please install Statistics and Machine Learning Toolbox.');
assert(exist('fitcecoc', 'file') == 2, ...
    'Missing fitcecoc. Please install Statistics and Machine Learning Toolbox.');

fprintf('Required toolbox functions: OK\n');

for i = 1:numel(requiredFiles)
    assert(exist(fullfile(projectRoot, requiredFiles{i}), 'file') == 2 || ...
        exist(requiredFiles{i}, 'file') == 2, 'Missing file: %s', requiredFiles{i});
end
fprintf('Project files: OK\n');

datasetFolder = fullfile(projectRoot, 'data', 'Hand_Posture_Easy_Stu');
classes = {'A', 'C', 'Five', 'V'};
assert(exist(datasetFolder, 'dir') == 7, 'Dataset folder not found: %s', datasetFolder);

for i = 1:numel(classes)
    classFolder = fullfile(datasetFolder, classes{i});
    images = dir(fullfile(classFolder, '*.png'));
    assert(numel(images) > 0, 'No PNG images found in %s', classFolder);
    if i == 1
        sampleImagePath = fullfile(images(1).folder, images(1).name);
    end
    fprintf('%s images: %d\n', classes{i}, numel(images));
end

loaded = load(fullfile(projectRoot, 'models', 'gesture_model.mat'), 'model');
model = loaded.model;
assert(isfield(model, 'classes'), 'Model missing classes.');
assert(isfield(model, 'trainFeatures'), 'Model missing trainFeatures.');
assert(isfield(model, 'trainLabels'), 'Model missing trainLabels.');
assert(isfield(model, 'mu'), 'Model missing mu.');
assert(isfield(model, 'sigma'), 'Model missing sigma.');
assert(isfield(model, 'classifier'), 'Model missing classifier.');
feature = extract_features(imread(sampleImagePath));
assert(numel(model.mu) == numel(feature), ...
    'Model feature dimension does not match extract_features output. Re-run scripts/train.m.');

fprintf('Model file: OK\n');
fprintf('Validation accuracy in model: %.2f%%\n', model.validationAccuracy * 100);
fprintf('Environment check passed.\n');
