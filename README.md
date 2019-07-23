# MIPS32 多周期 CPU 示例代码

最简单的多周期 CPU 实现，可以仿真运行[监控程序](https://github.com/z4yx/supervisor-mips32)的基础版本。

核心部分约 400 行代码。

注：本实现中没有采用经典的 **控制信号** 概念，而是译码为一种更容易理解的 **中间表示**。前者从电路角度描述信号的选择，后者从逻辑角度描述指令接下来要做什么。体现在代码上就是，前者使用 `assign` 逐个描述输出信号的组合逻辑（从后向前），后者使用 `always @(*)` 针对每种情况描述所有输出信号（从前向后），最终由编译器完成组合逻辑的生成。

## 环境

使用 iverilog 编译，GTKWave 查看波形。

Linux 安装命令：

```sh
apt-get install iverilog gtkwave
```

macOS 安装命令：

```sh
brew install iverilog
brew cask install gtkwave
```

检查是否正确安装：

```sh
which iverilog vvp gtkwave
```

## 运行测试

```sh
make build      # 编译
make hex        # 为测试程序生成 16 进制数据文件
make test       # 仿真测试
```

用 GTKWave 打开 `test.vcd` 查看波形

## 目录结构

```
├── defs.v              定义常数
├── cpu             CPU 核心逻辑
│   ├── cpu.v           多周期 CPU 状态机
│   ├── io.v            IO 控制器
│   ├── alu.v           算术逻辑单元
│   ├── id.v            译码单元
│   └── regfile.v       寄存器堆
├── mock            模拟设备，用于测试
│   ├── ram.v           模拟 RAM
│   └── serial.v        模拟串口
├── program         测试程序
│   ├── monitor.bin     监控程序 二进制文件
│   ├── monitor.elf     监控程序 elf文件
├── test            测试（testbench）
│   └── test_cpu.v      仿真测试监控程序
```
