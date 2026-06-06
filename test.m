function test(varargin)
clc;

scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(scriptDir, 'src')));

paths = load_project_config(scriptDir);
[testFolder, modelPath] = parse_test_args(varargin, paths.testFolder, paths.modelPath);

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
