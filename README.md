# 机器视觉原理课程作业：HandSignC

[![MATLAB](https://img.shields.io/badge/MATLAB-R2020b%2B-orange)](https://www.mathworks.com/products/matlab.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> 本项目使用传统机器视觉方法识别四类手势：`A`、`C`、`Five`、`V`。项目包含预处理、特征提取、SVM/ECOC 分类器、训练脚本、测试脚本以及已经训练好的模型文件，不依赖深度学习框架。

## 目录

- [机器视觉原理课程作业：HandSignC](#机器视觉原理课程作业handsignc)
  - [目录](#目录)
  - [项目结构](#项目结构)
  - [环境配置](#环境配置)
  - [系统配置](#系统配置)
  - [模型结构](#模型结构)
  - [训练配置](#训练配置)
  - [输出文件](#输出文件)
  - [训练](#训练)
  - [测试](#测试)
  - [实验结果](#实验结果)

## 项目结构

```text
.
├── configs/default.yaml          # 数据集、测试集和模型路径配置
├── data/Hand_Posture_Easy_Stu/   # 四类手势数据集
├── models/gesture_model.mat      # 已训练模型
├── src/                          # 特征提取、归一化和预测函数
├── train.m                       # 训练入口
├── test.m                        # 测试入口
├── repoet.md                     # 实验报告
├── README.md
└── LICENSE
```

## 环境配置

建议使用 MATLAB R2020b 或更高版本运行本项目。代码中使用了 `imread`、`imresize`、`padarray`、`extractHOGFeatures`、`fitcecoc`、`templateSVM`、`cvpartition` 等函数，因此需要安装：

- Image Processing Toolbox
- Computer Vision Toolbox
- Statistics and Machine Learning Toolbox

运行前在 MATLAB 中切换到项目根目录，或将项目根目录加入当前工作路径。训练和测试脚本会自动把 `src/` 加入 MATLAB 搜索路径。

## 系统配置

默认路径写在 `configs/default.yaml` 中：

```yaml
paths:
  data_folder: "data/Hand_Posture_Easy_Stu"
  test_folder: "data/Hand_Posture_Easy_Stu"
  model_path: "models/gesture_model.mat"
```

其中 `data_folder` 是训练数据集目录，`test_folder` 是测试图片目录，`model_path` 是模型保存和加载路径。默认测试目录指向同一份数据集；如果需要测试自己的图片，可以修改 `test_folder`，或在运行 `test.m` 时通过参数指定。

## 模型结构

项目采用“传统特征 + 机器学习分类器”的流程：

1. 图像预处理：灰度化、像素归一化、缩放到 `64x64`、Otsu 阈值分割、保留最大连通区域。
2. 特征提取：从灰度图和二值掩膜中提取 HOG 特征、`4x4` 网格 LBP 直方图特征，并加入面积、宽高比、质心、周长、紧致度等几何特征。
3. 特征归一化：使用训练集均值和标准差进行标准化，标准差过小的维度按 1 处理。
4. 分类器：使用 RBF 核 SVM 作为基础分类器，并通过 ECOC 的 one-vs-all 策略完成四分类。

最终每张图片会被表示为一个人工特征向量，再输入分类器预测为 `A`、`C`、`Five` 或 `V`。

## 训练配置

训练脚本默认使用以下设置：

- 类别：`A`、`C`、`Five`、`V`
- 验证方式：5 次重复 10 折交叉验证
- 随机种子：以 `42` 为基础种子
- 分类器：RBF 核 SVM，`BoxConstraint = 5`
- 多分类策略：ECOC one-vs-all
- 模型输出：`models/gesture_model.mat`

训练数据需要按类别分别放在 `data/Hand_Posture_Easy_Stu/A`、`C`、`Five`、`V` 四个子目录中，图片格式为 PNG。

## 输出文件

训练完成后会生成或覆盖：

```text
models/gesture_model.mat
```

模型文件中保存了分类器、类别名、训练特征、归一化参数、验证准确率、混淆矩阵、数据集路径和特征说明等信息。测试脚本会加载该文件，并对测试目录下的 PNG 图片逐张输出预测类别。

## 训练

在 MATLAB 中进入项目根目录后运行：

```matlab
train
```

也可以手动指定训练数据目录和模型输出路径：

```matlab
train('-data', 'data/Hand_Posture_Easy_Stu', '-out', 'models/gesture_model.mat')
```

训练过程会在命令行输出训练图片数量、平均交叉验证准确率、混淆矩阵以及模型保存路径。

## 测试

使用默认配置测试：

```matlab
test
```

也可以指定测试目录和模型文件：

```matlab
test('-test', 'data/Hand_Posture_Easy_Stu', '-model', 'models/gesture_model.mat')
```

测试脚本会递归读取测试目录中的 PNG 图片，并输出类似结果：

```text
A/img001.png: A
C/img001.png: C
Five/img001.png: Five
V/img001.png: V
```

## 实验结果

当前实验数据集共 200 张图片，每类 50 张。使用 5 次重复 10 折交叉验证后，平均验证准确率为：

```text
93.80%
```

第一轮验证得到的混淆矩阵如下：

| 真实类别 \ 预测类别 | A | C | Five | V |
| --- | ---: | ---: | ---: | ---: |
| A | 46 | 4 | 0 | 0 |
| C | 3 | 46 | 0 | 1 |
| Five | 2 | 0 | 48 | 0 |
| V | 1 | 0 | 0 | 49 |

结果显示，`Five` 和 `V` 的识别效果较好；`A` 与 `C` 之间存在一定混淆，主要原因可能是两类手势在部分样本中的轮廓和弯曲形态较接近。
