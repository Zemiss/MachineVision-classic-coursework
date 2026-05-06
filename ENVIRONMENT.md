# 环境说明

本项目主实现为 MATLAB 版本。`gesture_model.mat` 已随项目提供，测试阶段只需要加载模型并识别图片，不需要重新训练。

## 必需环境

- MATLAB R2020b 或更新版本；
- Image Processing Toolbox。

代码中使用到的工具箱函数：

| 函数 | 用途 |
| --- | --- |
| `imresize` | 图像尺寸归一化 |
| `padarray` | 周长特征计算时进行边界填充 |

## 不需要的环境

- Deep Learning Toolbox；
- Statistics and Machine Learning Toolbox；
- Python。

## 推荐检查命令

在 MATLAB 当前工作目录切换到项目根目录后运行：

```matlab
run('startup_check.m')
```

检查通过时会确认：

- MATLAB 版本；
- Image Processing Toolbox 关键函数；
- 项目必要文件；
- 数据集目录；
- `gesture_model.mat` 模型字段。

## 训练与测试

重新训练：

```matlab
run('train.m')
```

测试指定文件夹中的 PNG 图片：

```matlab
testFolder = 'test_images';
run('test.m')
```

如果没有 `test_images` 目录，`test.m` 会提示输入测试图片文件夹路径。

## MATLAB 启动失败排查

如果 MATLAB 命令行运行时报类似错误：

```text
无法与所需的 MathWorks 服务通信
错误 5001 / 5201
```

这通常是 MATLAB 授权服务、登录状态、网络代理或 MathWorks 本地服务通信问题，不是本项目代码错误。需要先保证 MATLAB 本身能正常执行：

```matlab
disp('matlab ok')
```

再运行本项目脚本。
