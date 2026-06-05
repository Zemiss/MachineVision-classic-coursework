# 传统手势识别实验报告

## 一、实验目的

本实验旨在使用传统机器视觉方法完成手势图像识别任务。实验对象为四类手势图像，分别为 `A`、`C`、`Five` 和 `V`。通过本实验，需要掌握图像预处理、二值分割、连通区域提取、人工特征构造以及机器学习分类器训练的基本流程，并验证传统特征结合分类模型在简单手势识别任务中的效果。

本实验的主要目标如下：

1. 掌握灰度化、尺寸归一化、阈值分割和最大连通区域提取等图像预处理方法。
2. 理解 HOG、LBP 和几何特征在手势识别中的作用。
3. 使用 RBF 核 SVM 分类器，并通过 ECOC 方法实现多分类识别。
4. 通过交叉验证评估模型性能，并根据混淆矩阵分析识别效果。
5. 完成训练、模型保存和测试图像批量识别的完整实验流程。

## 二、实验原理

### 2.1 图像预处理原理

手势图像通常包含背景、光照变化和手势区域差异。为了降低这些因素对识别结果的影响，实验首先对输入图像进行预处理。

程序先将彩色图像转换为灰度图像，若图像像素范围为 `0-255`，则归一化到 `0-1`。随后将图像统一缩放为 `64x64`，保证后续特征提取时输入尺寸一致。

在分割阶段，程序使用 Otsu 阈值法自动计算灰度阈值。Otsu 方法通过最大化类间方差来确定前景和背景的分割阈值。由于不同图像中手势区域可能表现为较亮或较暗区域，程序分别构造亮区域和暗区域掩膜，并选择面积较小的一类作为候选手势区域。之后保留最大连通区域，以减少背景噪声和零散干扰区域。

### 2.2 特征提取原理

本实验采用人工特征融合方案，主要包括 HOG 特征、LBP 特征和几何特征。

HOG 特征用于描述图像局部梯度方向分布，能够反映手势轮廓和边缘结构。程序分别在灰度图像和二值掩膜图像上提取 HOG 特征，使模型同时获得纹理边缘和形状边缘信息。

LBP 特征用于描述局部纹理模式。程序将图像划分为 `4x4` 网格，在每个网格中统计 LBP 编码直方图，从而保留局部空间分布信息。LBP 特征同样分别从灰度图像和二值掩膜图像中提取。

几何特征用于描述手势区域的整体形状，包括面积比例、宽度、高度、宽高比、质心位置、周长估计值和紧致度等。这些特征能够帮助区分形状差异明显的手势。

最终特征向量由以下部分组成：

| 特征类型 | 维度 | 作用 |
| --- | ---: | --- |
| 灰度 HOG | 324 | 描述灰度图像边缘方向分布 |
| 掩膜 HOG | 324 | 描述手势二值区域轮廓形状 |
| 灰度 LBP | 256 | 描述灰度图像局部纹理模式 |
| 掩膜 LBP | 256 | 描述二值手势区域局部结构 |
| 几何特征 | 8 | 描述面积、宽高比、质心和紧致度等整体形状 |
| 合计 | 1168 | 多特征融合表示 |

### 2.3 分类识别原理

实验使用 RBF 核 SVM 作为基础分类器。SVM 的基本思想是在特征空间中寻找最优分类超平面，使不同类别样本之间的间隔尽可能大。RBF 核函数可以处理非线性分类问题，适合手势特征之间边界不完全线性的情况。

由于 SVM 本身更适合二分类任务，实验通过 ECOC 方法将四分类问题拆分为多个二分类问题，再综合多个二分类器的输出得到最终类别。训练阶段使用固定随机种子和重复交叉验证评估模型稳定性，最终将训练好的模型保存到 `models/gesture_model.mat`。

## 三、实验环境

本实验使用 MATLAB 实现，主要依赖以下工具箱：

1. MATLAB R2020b 或更高版本。
2. Image Processing Toolbox。
3. Computer Vision Toolbox。
4. Statistics and Machine Learning Toolbox。

项目主要目录如下：

```text
classic/
├── data/Hand_Posture_Easy_Stu/   # 四类手势数据集
├── models/gesture_model.mat      # 已训练模型
├── src/                          # 核心函数
├── scripts/                      # 训练、测试和环境检查脚本
├── test_images/                  # 测试图像目录
├── README.md
└── ENVIRONMENT.md
```

## 四、实验步骤

### 4.1 准备数据集

将手势图像按照类别存放在 `data/Hand_Posture_Easy_Stu/` 目录下。数据集共包含 200 张图像，每类 50 张，类别包括 `A`、`C`、`Five` 和 `V`。

### 4.2 检查运行环境

在 MATLAB 中切换到项目根目录，运行环境检查脚本：

```matlab
run('scripts/startup_check.m')
```

该脚本用于检查 MATLAB 环境、数据集目录和模型文件是否满足运行要求。

### 4.3 训练模型

如需重新训练模型，运行训练脚本：

```matlab
run('scripts/train.m')
```

训练脚本会读取数据集图像，依次执行预处理、特征提取、特征归一化、交叉验证和模型训练。训练完成后，模型保存到：

```text
models/gesture_model.mat
```

### 4.4 测试模型

将待识别 PNG 图像放入 `test_images/` 目录，然后运行：

```matlab
run('scripts/evaluate.m')
```

测试脚本会加载已经训练好的模型，对 `test_images/` 目录下的所有 PNG 图像进行批量识别，并在命令行中输出每张图像的预测类别。

## 五、程序代码

### 5.1 图像预处理代码

图像预处理函数位于 `src/preprocess_image.m`，核心代码如下：

```matlab
function data = preprocess_image(img)
    if ndims(img) == 3
        img = 0.2989 * double(img(:, :, 1)) + ...
              0.5870 * double(img(:, :, 2)) + ...
              0.1140 * double(img(:, :, 3));
    else
        img = double(img);
    end

    if max(img(:)) > 1
        gray = img / 255;
    else
        gray = img;
    end

    resizedGray = imresize(gray, [64, 64]);
    threshold = otsu_threshold(resizedGray);
    darkMask = resizedGray < threshold;
    lightMask = resizedGray > threshold;

    if sum(lightMask(:)) < sum(darkMask(:))
        mask = lightMask;
    else
        mask = darkMask;
    end

    mask = keep_largest_component(mask);
    data.gray = resizedGray;
    data.mask = mask;
end
```

该函数完成灰度化、归一化、尺寸统一、Otsu 阈值分割和最大连通区域提取。

### 5.2 特征提取代码

特征提取函数位于 `src/extract_features.m`，核心代码如下：

```matlab
function feature = extract_features(img)
    data = preprocess_image(img);
    gray = data.gray;
    mask = data.mask;

    gray = pad_to_square(gray, mean(gray(:)));
    mask = pad_to_square(double(mask), 0) > 0.5;

    gray64 = imresize(gray, [64, 64]);
    mask64 = imresize(double(mask), [64, 64]) > 0.5;

    hogGray = extractHOGFeatures(gray64, 'CellSize', [16, 16]);
    hogMask = extractHOGFeatures(double(mask64), 'CellSize', [16, 16]);
    lbpGray = extract_lbp_grid_histogram(gray64, 4, 4, 16);
    lbpMask = extract_lbp_grid_histogram(double(mask64), 4, 4, 16);

    [rows, cols] = find(mask);
    if isempty(rows)
        geometry = zeros(1, 8);
    else
        area = sum(mask(:)) / numel(mask);
        height = (max(rows) - min(rows) + 1) / size(mask, 1);
        width = (max(cols) - min(cols) + 1) / size(mask, 2);
        aspect = width / max(height, eps);
        centroidRow = mean(rows) / size(mask, 1);
        centroidCol = mean(cols) / size(mask, 2);
        perimeter = estimate_perimeter(mask) / numel(mask);
        compactness = perimeter^2 / max(area, eps);
        geometry = [area, width, height, aspect, centroidRow, ...
                    centroidCol, perimeter, compactness];
    end

    feature = double([hogGray, hogMask, lbpGray, lbpMask, geometry]);
end
```

该函数将图像裁剪到手势区域附近，并补齐为正方形，再提取 HOG、LBP 和几何特征，最终生成 1168 维特征向量。

### 5.3 模型训练代码

训练脚本位于 `scripts/train.m`，核心代码如下：

```matlab
classes = {'A', 'C', 'Five', 'V'};
numRepeats = 5;
numFolds = 10;
baseSeed = 42;

template = templateSVM( ...
    'KernelFunction', 'rbf', ...
    'KernelScale', 'auto', ...
    'BoxConstraint', 5, ...
    'Standardize', false);

for rep = 1:numRepeats
    rng(baseSeed + rep);
    cv = cvpartition(labelsCat, 'KFold', numFolds);

    for fold = 1:cv.NumTestSets
        trainMask = training(cv, fold);
        testMask = test(cv, fold);

        [splitTrainFeatures, splitMu, splitSigma] = ...
            normalize_features(features(trainMask, :));
        splitTestFeatures = ...
            (features(testMask, :) - splitMu) ./ splitSigma;

        foldModel = fitcecoc(splitTrainFeatures, labelsCat(trainMask), ...
            'Coding', 'onevsall', 'Learners', template);

        foldPredicted = cellstr(string(predict(foldModel, splitTestFeatures)));
        repeatPredicted(testMask) = foldPredicted;
    end
end
```

该脚本使用 5 次重复 10 折交叉验证评估模型，并在完整数据集上训练最终分类器。

### 5.4 手势预测代码

预测函数位于 `src/predict_gesture.m`，核心代码如下：

```matlab
function label = predict_gesture(img, model)
    feature = extract_features(img);
    feature = (feature - model.mu) ./ model.sigma;

    if isfield(model, 'classifier') && ~isempty(model.classifier)
        predicted = predict(model.classifier, feature);
        label = char(string(predicted));
    else
        label = knn_predict(feature, model.trainFeatures, ...
            model.trainLabels, model.classes, model.k);
        label = label{1};
    end
end
```

该函数先提取输入图像特征，再使用训练阶段保存的均值和标准差进行归一化，最后调用分类器输出预测类别。

### 5.5 批量测试代码

批量测试脚本位于 `scripts/evaluate.m`，核心代码如下：

```matlab
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
```

该脚本会遍历测试目录中的 PNG 图像，并逐一输出识别结果。

## 六、实验结果显示

实验数据集共包含 200 张手势图像，每类 50 张。训练时使用固定随机种子 `42`，采用 5 次重复 10 折交叉验证。当前模型记录的平均验证准确率为：

```text
93.80%
```

混淆矩阵如下：

| 真实类别 \ 预测类别 | A | C | Five | V |
| --- | ---: | ---: | ---: | ---: |
| A | 46 | 4 | 0 | 0 |
| C | 3 | 46 | 0 | 1 |
| Five | 2 | 0 | 48 | 0 |
| V | 1 | 0 | 0 | 49 |

从混淆矩阵可以看出，`Five` 和 `V` 的识别效果较好，分别有 48 张和 49 张图像被正确分类。`A` 与 `C` 之间存在一定混淆，说明这两类手势在当前特征空间中有部分样本边界较接近。

批量测试时，程序会输出类似以下格式的结果：

```text
image_01.png: A
image_02.png: C
image_03.png: Five
image_04.png: V
```

实际输出结果取决于 `test_images/` 目录中的测试图片内容。

## 七、实验分析总结

本实验使用传统机器视觉方法完成了四类手势识别任务。整体流程包括图像灰度化、尺寸归一化、Otsu 阈值分割、最大连通区域提取、人工特征提取、特征归一化和 SVM 多分类识别。实验结果表明，在数据规模较小、类别较固定、背景相对简单的条件下，传统特征结合 SVM 分类器能够取得较好的识别效果，验证准确率达到 93.80%。

从特征设计角度看，HOG 特征能够有效描述手势边缘和轮廓方向，LBP 特征能够补充局部纹理信息，几何特征能够提供整体形状差异。多种特征融合后，模型获得了比单一特征更完整的手势表达。

从分类结果看，`Five` 和 `V` 的区分效果较好，主要原因是两类手势轮廓差异明显。`A` 和 `C` 之间出现较多误分类，可能是因为部分样本在二值化后轮廓相近，且手指弯曲形态或拍摄角度变化导致特征差异减小。

本实验方法的优点是不依赖深度学习框架，模型结构清晰，训练速度较快，可解释性较强。缺点是对光照、背景、手势位置和拍摄角度仍然比较敏感，泛化能力受人工特征设计影响较大。如果进一步改进，可以从以下方面入手：

1. 增加训练数据数量，提高不同光照、角度和背景下的样本覆盖。
2. 引入更稳定的手部区域分割方法，降低背景干扰。
3. 对 HOG、LBP 和几何特征参数进行调优。
4. 尝试 PCA 等降维方法，减少冗余特征。
5. 与 CNN 等深度学习方法进行对比实验，分析传统方法和深度方法的性能差异。

综上，本实验较完整地实现了基于传统机器视觉的手势识别流程，并通过交叉验证和混淆矩阵证明了模型具有较好的分类效果。
