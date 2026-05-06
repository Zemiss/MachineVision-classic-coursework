# 传统手势识别

[![MATLAB](https://img.shields.io/badge/MATLAB-R2020b%2B-orange)](https://www.mathworks.com/products/matlab.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

本项目使用传统机器视觉方法识别四类手势：`A`、`C`、`Five`、`V`。项目包含训练脚本、独立测试脚本、预处理、特征提取、KNN 分类器、已训练模型和运行说明，不依赖深度学习框架。

## 特性

- 使用灰度化、尺寸归一化、Otsu 阈值分割、连通区域提取等传统视觉处理流程。
- 使用手工特征和 KNN 分类器，不使用深度学习。
- `test.m` 可直接加载 `gesture_model.mat` 批量识别 PNG 图片。
- 文档、环境要求、贡献规范和仓库模板已按开源项目常见结构整理。

## 快速开始

在 MATLAB 中将当前工作目录切换到项目根目录，然后运行环境检查：

```matlab
run('startup_check.m')
```

重新训练模型：

```matlab
run('train.m')
```

测试指定 PNG 图片目录：

```matlab
testFolder = 'test_images';
run('test.m')
```

如果 `test_images` 不存在，`test.m` 会提示输入测试图片文件夹路径。输出格式如下：

```text
test_001.png: A
test_002.png: Five
test_003.png: V
```

## 环境要求

必需环境：

- MATLAB R2020b 或更新版本；
- Image Processing Toolbox。

不需要：

- Deep Learning Toolbox；
- Statistics and Machine Learning Toolbox；
- Python 运行环境。

更完整的环境说明见 [ENVIRONMENT.md](ENVIRONMENT.md)。

## 仓库结构

```text
classic/
├── data/Hand_Posture_Easy_Stu/   # 四类手势训练数据
│   ├── A/
│   ├── C/
│   ├── Five/
│   └── V/
├── docs/                         # 维护与结构文档
├── .github/                      # Issue 和 PR 模板
├── train.m                       # 训练脚本
├── test.m                        # 独立测试脚本
├── startup_check.m               # 环境与文件检查
├── preprocess_image.m            # 图像预处理
├── extract_features.m            # 特征提取
├── normalize_features.m          # 特征归一化
├── knn_predict.m                 # KNN 分类
├── predict_gesture.m             # 单张图片预测接口
├── gesture_model.mat             # 已训练模型
├── ENVIRONMENT.md                # 环境说明
├── requirements.md               # 作业要求对应说明
├── CONTRIBUTING.md               # 贡献指南
├── CODE_OF_CONDUCT.md            # 行为准则
├── CHANGELOG.md                  # 变更记录
└── LICENSE                       # 开源许可证
```

详细结构说明见 [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)。

## 算法流程

```text
读取图像
→ 灰度化与尺寸归一化
→ Otsu 阈值分割
→ 最大连通区域提取
→ 手工特征提取
→ 特征归一化
→ KNN 分类
→ 输出类别
```

## 特征设计

`extract_features.m` 输出 296 维特征：

| 特征类型 | 维度 | 说明 |
| --- | ---: | --- |
| 灰度缩略图 | 256 | 将图像缩放为 `16x16` 后展开 |
| 几何特征 | 8 | 面积、宽度、高度、宽高比、质心、周长、紧致度 |
| 行方向投影 | 16 | 二值手势区域按行统计 |
| 列方向投影 | 16 | 二值手势区域按列统计 |

训练阶段保存均值和标准差，测试阶段复用同一组参数完成归一化。

## 模型

分类器为 KNN，`k = 3`。模型文件为 `gesture_model.mat`，包含：

- `model.classes`：类别列表；
- `model.trainFeatures`：训练特征；
- `model.trainLabels`：训练标签；
- `model.mu` 和 `model.sigma`：归一化参数；
- `model.validationAccuracy`：验证准确率；
- `model.confusionMatrix`：混淆矩阵。

`test.m` 只加载模型并预测，不会重新训练。

## 当前结果

数据集共 200 张图片，每类 50 张。训练脚本固定随机种子 `42`，按 80/20 分层划分验证集，然后使用全部图片保存最终模型。

当前 `gesture_model.mat` 记录的验证准确率：

```text
82.50%
```

混淆矩阵行表示真实类别，列表示预测类别：

| 真实 \ 预测 | A | C | Five | V |
| --- | ---: | ---: | ---: | ---: |
| A | 7 | 1 | 1 | 1 |
| C | 2 | 7 | 0 | 1 |
| Five | 1 | 0 | 9 | 0 |
| V | 0 | 0 | 0 | 10 |

## 贡献

提交代码前请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。本项目保持小而清晰的结构，优先接受能直接提升识别效果、可维护性或文档准确性的改动。

## 许可证

本项目使用 [MIT License](LICENSE)。
