clc;

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));

testFolder = fullfile(projectRoot, 'test_images');
modelPath = fullfile(projectRoot, 'models', 'gesture_model.mat');

if ~exist(testFolder, 'dir')
    error('Test image folder not found: %s', testFolder);
end

if ~exist(modelPath, 'file')
    error('Model file not found: %s', modelPath);
end

loaded = load(modelPath, 'model');
model = loaded.model;

imageFiles = dir(fullfile(testFolder, '**', '*.png'));
if isempty(imageFiles)
    error('No PNG images found in %s', testFolder);
end

for i = 1:numel(imageFiles)
    imagePath = fullfile(imageFiles(i).folder, imageFiles(i).name);
    img = imread(imagePath);
    label = predict_gesture(img, model);
    relPath = erase(imagePath, [testFolder filesep]);
    fprintf('%s: %s\n', relPath, label);
end
