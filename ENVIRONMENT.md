# 环境说明

本项目主实现为 MATLAB 版本。`models/gesture_model.mat` 已随项目提供，测试阶段只需要加载模型并识别图片，不需要重新训练。

## 必需环境

- MATLAB R2020b 或更高版本
- Image Processing Toolbox

## 用到的工具箱函数

| 函数 | 用途 |
| --- | --- |
| `imresize` | 图像尺寸归一化 |
| `padarray` | 周长和形状相关计算中的边界处理 |


## 推荐命令

在 MATLAB 当前工作目录切换到项目根目录后运行：

```matlab
run('scripts/startup_check.m')
```

通过检查后，说明以下内容可用：

- MATLAB 版本
- Image Processing Toolbox 关键函数
- 项目必须文件
- 数据集目录
- `models/gesture_model.mat` 模型文件

## 训练与测试

重新训练：

```matlab
run('scripts/train.m')
```

批量测试：

```matlab
testFolder = 'test_images';
run('scripts/test.m')
```

如果没有 `test_images` 目录，`scripts/test.m` 会提示输入测试图片文件夹路径。

