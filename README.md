# 机器视觉原理课程作业：传统手势识别

[![MATLAB](https://img.shields.io/badge/MATLAB-R2020b%2B-orange)](https://www.mathworks.com/products/matlab.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

本项目使用传统机器视觉方法识别四类手势：`A`、`C`、`Five`、`V`。项目包含预处理、特征提取、KNN 分类器、训练脚本、测试脚本以及已经训练好的模型文件，不依赖深度学习框架。

## 项目内容

- 基于灰度化、尺寸归一化、Otsu 阈值分割、连通域提取等传统图像处理流程
- 基于人工特征和 KNN 的分类方案
- 已训练模型文件 `models/gesture_model.mat`
- MATLAB 启动检查、训练、测试脚本

## 目录结构

```text
classic/
├── data/Hand_Posture_Easy_Stu/   # 四类手势数据集
├── models/gesture_model.mat      # 已训练模型
├── src/classic/                  # 核心实现
├── scripts/                      # 可直接运行的脚本
├── docs/                         # 结构说明和项目文档
├── README.md
├── ENVIRONMENT.md
└── LICENSE
```

## 主要脚本

这些脚本都在 `scripts/` 目录下：

- `scripts/startup_check.m`：检查 MATLAB 环境、数据集和模型文件是否齐全
- `scripts/train.m`：重新训练模型并保存到 `models/gesture_model.mat`
- `scripts/test.m`：加载模型并批量识别 PNG 图片

## 快速开始

1. 在 MATLAB 中切换到项目根目录。
2. 运行环境检查：

```matlab
run('scripts/startup_check.m')
```

3. 如需重新训练模型：

```matlab
run('scripts/train.m')
```

4. 批量测试图片：

```matlab
testFolder = 'test_images';
run('scripts/test.m')
```

如果 `test_images` 不存在，脚本会提示你输入测试图片文件夹路径。

## 模型文件

训练完成后，模型会保存为 `models/gesture_model.mat`。该文件中主要包含：

- `model.classes`
- `model.trainFeatures`
- `model.trainLabels`
- `model.mu`
- `model.sigma`
- `model.validationAccuracy`
- `model.confusionMatrix`

测试脚本只加载模型，不会重新训练。

## 环境要求

必需环境：

- MATLAB R2020b 或更高版本
- Image Processing Toolbox

不需要：

- Deep Learning Toolbox
- Statistics and Machine Learning Toolbox
- Python 运行环境

更详细的环境说明见 [ENVIRONMENT.md](ENVIRONMENT.md)。

## 算法流程

```text
读取图像
  -> 灰度化和尺寸归一化
  -> Otsu 阈值分割
  -> 最大连通区域提取
  -> 手工特征提取
  -> 特征归一化
  -> KNN 分类
  -> 输出类别
```

## 特征设计

`extract_features.m` 输出 296 维特征，主要由以下部分组成：

| 特征类型 | 维度 | 说明 |
| --- | ---: | --- |
| 灰度缩略图 | 256 | 将图像缩放为 `16x16` 后展开 |
| 几何特征 | 8 | 面积、宽度、高度、宽高比、质心、周长、紧致度等 |
| 行方向投影 | 16 | 二值手势区域按行统计 |
| 列方向投影 | 16 | 二值手势区域按列统计 |

训练阶段会保存均值和标准差，测试阶段使用同一组参数做归一化。

## 模型说明

分类器使用 KNN，`k = 3`。`models/gesture_model.mat` 中保存了训练好的模型及验证结果。

## 当前结果

数据集共 200 张图片，每类 50 张。训练时使用固定随机种子 `42`，按 80/20 划分验证集。

当前模型记录的验证准确率为：

```text
95.00%
```

混淆矩阵如下：

| 真实 \ 预测 | A | C | Five | V |
| --- | ---: | ---: | ---: | ---: |
| A | 7 | 1 | 1 | 1 |
| C | 2 | 7 | 0 | 1 |
| Five | 1 | 0 | 9 | 0 |
| V | 0 | 0 | 0 | 10 |

## 说明

- 根目录下不再保留 `train.m`、`test.m`、`startup_check.m`，统一使用 `scripts/` 目录下的入口脚本。
- 如果你只想直接测试现成模型，运行 `scripts/test.m` 即可。
- 如果你修改了特征提取或分类参数，建议先运行 `scripts/train.m` 重新生成模型。
