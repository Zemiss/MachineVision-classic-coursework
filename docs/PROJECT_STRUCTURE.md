# 项目结构说明

本项目是一个 MATLAB 传统手势识别仓库，核心代码放在 `src/classic/`，运行入口放在 `scripts/`，训练好的模型放在 `models/`。

## 顶层文件

| 路径 | 说明 |
| --- | --- |
| `README.md` | 项目总说明 |
| `ENVIRONMENT.md` | 环境与运行说明 |
| `LICENSE` | 开源许可证 |
| `.gitignore` | Git 忽略规则 |
| `models/gesture_model.mat` | 训练好的模型 |

## 代码目录

| 路径 | 说明 |
| --- | --- |
| `src/classic/preprocess_image.m` | 图像预处理 |
| `src/classic/extract_features.m` | 特征提取 |
| `src/classic/normalize_features.m` | 特征归一化 |
| `src/classic/knn_predict.m` | KNN 分类 |
| `src/classic/predict_gesture.m` | 单张图片预测接口 |

## 运行脚本

| 路径 | 说明 |
| --- | --- |
| `scripts/startup_check.m` | 检查 MATLAB 环境、数据集和模型文件 |
| `scripts/train.m` | 训练模型并保存到 `models/gesture_model.mat` |
| `scripts/test.m` | 加载模型并批量识别 PNG 图片 |

## 数据与资源

| 路径 | 说明 |
| --- | --- |
| `data/Hand_Posture_Easy_Stu/` | 四类手势数据集 |
| `data/README.md` | 数据集说明 |
| `assets/` | 图片、文档配图等静态资源 |
| `tests/` | 测试相关文件 |

## 运行方式

在 MATLAB 中切换到项目根目录后，运行：

```matlab
run('scripts/startup_check.m')
run('scripts/train.m')
testFolder = 'test_images';
run('scripts/test.m')
```

## 约定

- 运行入口统一放在 `scripts/`
- 核心实现统一放在 `src/classic/`
- 训练模型统一保存在 `models/gesture_model.mat`
- 本地测试图片建议放在 `test_images/`

