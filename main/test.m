function test(varargin)
clc;

scriptDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(scriptDir);
addpath(genpath(fullfile(scriptDir, 'src')));

defaultTest = fullfile(projectRoot, 'test_images');
defaultModel = fullfile(scriptDir, 'models', 'gesture_model.mat');
[testFolder, modelPath] = parse_test_args(varargin, defaultTest, defaultModel);

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
end

function [testFolder, modelPath] = parse_test_args(args, defaultTest, defaultModel)
    testFolder = defaultTest;
    modelPath = defaultModel;

    if mod(numel(args), 2) ~= 0
        error('Arguments must be name-value pairs, for example: test(''-test'', ''C:/images'', ''-model'', ''C:/model.mat'')');
    end

    for i = 1:2:numel(args)
        name = char(string(args{i}));
        value = char(string(args{i + 1}));

        switch lower(name)
            case {'-test', 'test'}
                testFolder = value;
            case {'-model', 'model'}
                modelPath = value;
            otherwise
                error('Unknown argument: %s. Supported arguments: -test, -model', name);
        end
    end
end
