# 项目结构说明

本项目是一个小型 MATLAB 传统手势识别项目。为了保持脚本可直接运行，核心 `.m` 文件保留在项目根目录。

## 顶层文件

| 路径 | 说明 |
| --- | --- |
| `train.m` | 读取训练数据、提取特征、验证模型并保存 `gesture_model.mat` |
| `test.m` | 加载模型并批量预测指定目录中的 PNG 图片 |
| `startup_check.m` | 检查 MATLAB 环境、关键函数、必要文件、数据集和模型字段 |
| `preprocess_image.m` | 完成灰度化、尺寸归一化、阈值分割和连通区域处理 |
| `extract_features.m` | 提取灰度、几何和投影特征 |
| `normalize_features.m` | 计算并应用特征归一化参数 |
| `knn_predict.m` | 使用 KNN 完成分类 |
| `predict_gesture.m` | 对单张图片执行完整预测流程 |
| `gesture_model.mat` | 已训练模型，供测试脚本直接加载 |

## 目录

| 路径 | 说明 |
| --- | --- |
| `data/Hand_Posture_Easy_Stu/` | 项目数据集，按类别分为 `A`、`C`、`Five`、`V` |
| `docs/` | 项目维护、结构和补充说明文档 |
| `.github/` | Issue 与 Pull Request 模板 |

## 维护约定

- 算法入口保持为 `train.m` 和 `test.m`。
- 本项目不使用包管理器，依赖以文档形式写入 `ENVIRONMENT.md`。
- 本地临时测试图片建议放入 `test_images/`，该目录不会提交到 Git。
- `gesture_model.mat` 是验收和演示所需文件，默认保留在版本控制中。
