# SubDroid - 子域名枚举与安全扫描工具

作者: Satoru, LinTu  
指导师傅: NightWatch Diffany

## 简介

SubDroid 是一款针对网络安全领域的自动化子域名枚举与安全扫描工具。它专为渗透测试人员、安全研究人员及开发者设计,旨在帮助快速发现潜在的安全问题。SubDroid 集成了多个强大的安全工具,通过简洁的命令行界面提供了高效的子域名扫描、DNS 查询、端口扫描、活跃性检测、指纹识别、漏洞扫描等功能。

## 设计理念

SubDroid 的设计理念是通过联动多种开源工具,为用户提供全面而高效的扫描体验,省去了手动调用每个工具的繁琐过程。然而,值得注意的是,由于工具集成的并行性问题,某些功能在高并发或大规模扫描时可能面临性能瓶颈或稳定性问题。尽管如此,SubDroid 依然是一个简单易用的解决方案,适合中小型目标的安全测试。

## 核心特性

- **自动化扫描**: 自动调用子域名枚举、DNS 查询、活跃性检测、端口扫描、指纹识别、漏洞扫描等常见安全测试任务。
- **结果整合**: 所有扫描结果按模块保存到指定文件,便于后续查阅与分析。
- **灵活配置**: 用户可灵活配置扫描流程中的每一个细节。
- **简单易用**: 通过简单的命令行调用,快速启动扫描任务。
- **集成流行工具**: 基于多个知名开源工具进行集成和联动。

## 支持的工具集

- subfinder: 子域名枚举
- assetfinder: 子域名收集
- dnsx: DNS 查询
- puredns: 域名存活检查
- Web-SurvivalScan: 域名存活检查
- nuclei: 漏洞扫描
- ffuf: 目录和文件模糊扫描
- masscan: 大规模端口扫描
- TideFinger: 指纹信息探测

## 环境要求

- **操作系统**: 主要支持 Linux,其他系统可能需要额外配置
- **Python**: Python 3 环境
- **依赖工具**: subfinder, assetfinder, dnsx, puredns, nuclei, ffuf, masscan, webscanner, tidefinger
- **可选**: 建议使用 Python 虚拟环境(venv)管理项目依赖

## 安装与配置

1. 克隆项目:
   ```bash
   git clone https://github.com/satoru-qwq/SubDroid.git
   cd SubDroid
   ```

2. 创建虚拟环境并安装依赖:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. 安装必要的工具(以 subfinder 为例):
   ```bash
   go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
   ```

4. 配置文件: 默认输出到 `combined_output.txt`,可在运行时通过参数自定义。

## 使用说明

基本命令格式:
```bash
./subdroid.sh <domain> [output_file] [-crawl]
```

参数说明:
- `<domain>`: 必填,目标域名
- `[output_file]`: 可选,指定输出文件
- `[-crawl]`: 可选,启用爬虫扫描功能(尚未完全实现)

示例:
1. 基本用法:
   ```bash
   ./subdroid.sh example.com
   ```

2. 自定义输出文件名:
   ```bash
   ./subdroid.sh example.com output.txt
   ```

3. 启用爬虫扫描(假设该功能已完成):
   ```bash
   ./subdroid.sh example.com output.txt -crawl
   ```

## 运行流程

1. 子域名扫描: subfinder 和 assetfinder
2. DNS 查询: dnsx
3. 活跃性检测: puredns
4. 端口扫描: masscan
5. 指纹识别: f1nger.py
6. 漏洞扫描: nuclei
7. 目录模糊扫描: ffuf

## 输出结果

结果保存在 `result/<domain>` 目录下,按模块分类:
- SUB: 子域名列表
- IP: 域名到 IP 映射
- ALIVE: 活跃子域名列表
- PORTS: 端口扫描结果
- Finger: 指纹识别结果
- Leak!: 漏洞扫描结果
- dir: 目录模糊扫描结果

## 注意事项

- **并行性问题**: 可能在处理大量数据时遇到性能瓶颈
- **权限要求**: 部分工具需要管理员权限
- **清理旧结果**: 建议每次扫描前清理旧的结果文件

## 性能与并行性注意

1. 工具之间的依赖关系可能导致串行化执行
2. 部分工具(如 masscan)可能消耗大量资源
3. 高并发可能导致资源过载

## 贡献

欢迎安全研究人员和开发者参与贡献,提交 Bug 报告、建议或改进功能。

## License

SubDroid 遵循 MIT License。
