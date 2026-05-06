clear; clc;

requiredFiles = {
    'train.m'
    'test.m'
    'preprocess_image.m'
    'extract_features.m'
    'normalize_features.m'
    'knn_predict.m'
    'predict_gesture.m'
    'gesture_model.mat'
};

fprintf('Checking MATLAB environment...\n');
fprintf('MATLAB version: %s\n', version);

assert(exist('imresize', 'file') == 2, ...
    'Missing imresize. Please install Image Processing Toolbox.');
assert(exist('padarray', 'file') == 2, ...
    'Missing padarray. Please install Image Processing Toolbox.');

fprintf('Image Processing Toolbox functions: OK\n');

for i = 1:numel(requiredFiles)
    assert(exist(requiredFiles{i}, 'file') == 2, 'Missing file: %s', requiredFiles{i});
end
fprintf('Project files: OK\n');

datasetFolder = fullfile(pwd, 'data', 'Hand_Posture_Easy_Stu');
classes = {'A', 'C', 'Five', 'V'};
assert(exist(datasetFolder, 'dir') == 7, 'Dataset folder not found: %s', datasetFolder);

for i = 1:numel(classes)
    classFolder = fullfile(datasetFolder, classes{i});
    images = dir(fullfile(classFolder, '*.png'));
    assert(numel(images) > 0, 'No PNG images found in %s', classFolder);
    fprintf('%s images: %d\n', classes{i}, numel(images));
end

loaded = load('gesture_model.mat', 'model');
model = loaded.model;
assert(isfield(model, 'classes'), 'Model missing classes.');
assert(isfield(model, 'trainFeatures'), 'Model missing trainFeatures.');
assert(isfield(model, 'trainLabels'), 'Model missing trainLabels.');
assert(isfield(model, 'mu'), 'Model missing mu.');
assert(isfield(model, 'sigma'), 'Model missing sigma.');

fprintf('Model file: OK\n');
fprintf('Validation accuracy in model: %.2f%%\n', model.validationAccuracy * 100);
fprintf('Environment check passed.\n');
