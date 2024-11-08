#**SubDroid - 子域名枚举与安全扫描工具**

作者：Satoru，LinTu
指导师傅：NightWatch Diffany


SubDroid 是一款针对网络安全领域的自动化子域名枚举与安全扫描工具，专为渗透测试人员、安全研究人员及开发者设计，旨在帮助快速发现潜在的安全问题。它集成了多个强大的安全工具，通过简洁的命令行界面提供了高效的子域名扫描、DNS 查询、端口扫描、活跃性检测、指纹识别、漏洞扫描等功能。

SubDroid 的设计理念是通过联动多种开源工具，为用户提供全面而高效的扫描体验，省去了手动调用每个工具的繁琐过程。然而，值得注意的是，由于工具集成的并行性问题，某些功能在高并发或大规模扫描时可能面临性能瓶颈或稳定性问题。尽管如此，SubDroid 依然是一个简单易用的解决方案，适合中小型目标的安全测试。

### 核心特性
- **自动化扫描**：SubDroid 会自动化调用子域名枚举、DNS 查询、活跃性检测、端口扫描、指纹识别、漏洞扫描等常见的安全测试任务。用户无需繁琐的手动配置，工具本身已整合好各种子工具。
  
- **结果整合**：所有扫描结果会按模块保存到指定文件，便于后续的查阅与分析。每个模块（如子域名收集、漏洞扫描、端口扫描等）都有单独的输出文件，便于您细致地查看每一步的结果。

- **灵活配置**：用户可以灵活配置扫描流程中的每一个细节，如指定扫描输出文件、启用或禁用某些扫描模块等。

- **简单易用**：通过简单的命令行调用，用户无需对工具的每个部分进行复杂配置，快速启动扫描任务。

- **集成流行工具**：SubDroid 并不是一个从零开始的工具，而是基于多个知名开源工具（如 `subfinder`、`masscan`、`nuclei` 等）进行了集成和联动。这使得工具在功能上十分强大，但也有一些集成上的不足之处，尤其是在并行性和稳定性上。

### 支持的工具集
SubDroid 集成了多个成熟的安全工具来提供全面的扫描功能：

- **subfinder**：快速、高效的子域名枚举工具，能够从多种公共资源（如搜索引擎、API 等）收集子域名。
- **assetfinder**：另一个简单的子域名收集工具，基于 HTTP 请求方式来寻找子域名。
- **dnsx**：高效的 DNS 查询工具，用于将收集到的子域名解析为 IP 地址。
- **puredns**：检查域名是否存活的工具，确保目标子域名可以正常访问。
- **Web-SurvivalScan** 检查域名是否存活的工具，确保目标子域名可以正常访问。
- **nuclei**：漏洞扫描工具，能够基于已知模板对子域名进行快速扫描，寻找潜在的安全漏洞。
- **ffuf**：强大的目录和文件模糊扫描工具，用于发现隐藏的目录和文件。
- **masscan**：大规模端口扫描工具，能够快速扫描大量 IP 地址和端口。
- **TideFinger**: 强大的指纹信息探测工具
### 环境要求
- **操作系统**：工具设计以 Linux 为主，虽然其他操作系统（如 macOS、Windows）也能运行，但可能需要额外配置或调整。
- **Python**：需要 Python 3 环境。
- **依赖工具**：
  - `subfinder`
  - `assetfinder`
  - `dnsx`
  - `puredns`
  - `nuclei`
  - `ffuf`
  - `masscan`
  - `webscanner`
  - `tidefinger`
- **可选**：建议使用 Python 虚拟环境（venv）来管理项目依赖。

### 安装与配置
1. **克隆项目**：
   ```bash
   git clone https://github.com/satoru-qwq/SubDroid.git
   cd SubDroid
   ```

2. **创建虚拟环境并安装依赖**：
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **安装必要的工具**：
   比如，安装 `subfinder`：
   ```bash
   go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
   ```

4. **配置文件**：
   默认情况下，扫描结果会输出到 `combined_output.txt` 文件。如果您需要指定自定义文件名，可以在运行时通过参数传递。

### 使用说明
SubDroid 的命令行用法非常简便，您只需要在命令行中输入以下命令启动扫描：
```bash
./subdroid.sh <domain> [output_file] [-crawl]
```
- `<domain>`：必填，目标域名。
- `[output_file]`：可选，指定输出文件，默认会保存在 `combined_output.txt`。
- `[-crawl]`：可选，启用爬虫扫描功能（此功能尚未完全实现，默认关闭）。

#### 示例
1. **基本用法**：扫描目标域名，结果保存在默认文件：
   ```bash
   ./subdroid.sh example.com
   ```

2. **自定义输出文件名**：
   ```bash
   ./subdroid.sh example.com output.txt
   ```

3. **启用爬虫扫描**（假设该功能已完成）：
   ```bash
   ./subdroid.sh example.com output.txt -crawl
   ```

### 运行流程
1. **子域名扫描**：首先，通过 `subfinder` 和 `assetfinder` 收集目标域名的子域名。
2. **DNS 查询**：使用 `dnsx` 将这些子域名解析为对应的 IP 地址。
3. **活跃性检测**：通过 `puredns` 检查哪些子域名是活跃的。
4. **端口扫描**：使用 `masscan` 对活跃子域名对应的 IP 地址进行端口扫描。
5. **指纹识别**：通过 `f1nger.py` 对子域名进行指纹识别，分析服务器和技术栈。
6. **漏洞扫描**：利用 `nuclei` 扫描可能存在的漏洞。
7. **目录模糊扫描**：通过 `ffuf` 对子域名进行目录和文件模糊扫描，寻找潜在的隐藏资源。

### 输出结果
所有扫描结果会保存在 `result/<domain>` 目录下，并按照不同模块分类：
- **SUB**：所有收集到的子域名列表。
- **IP**：域名到 IP 的映射。
- **ALIVE**：活跃的子域名列表。
- **PORTS**：端口扫描结果。
- **Finger**：指纹识别结果。
- **Leak!**：漏洞扫描结果。
- **dir**：目录模糊扫描结果。

### 注意事项
- **并行性问题**：SubDroid 在进行多个扫描时可能会遇到并行性瓶颈，特别是在处理大量子域名或进行大规模端口扫描时。部分工具（如 `masscan`）需要较高的网络带宽和资源，可能会造成性能瓶颈。
  
- **权限要求**：一些工具（如 `masscan`）需要管理员权限（root）才能进行端口扫描。确保你有相应的权限来执行这些操作。

- **清理旧结果**：每次运行时，SubDroid 会自动为每个扫描任务生成一个新的结果目录。建议在执行新的扫描前清理旧的结果文件，避免目录冲突。

### 性能与并行性注意
由于 SubDroid 集成了多个工具，并行执行这些工具可能会导致性能瓶颈。具体的瓶颈可能出现在以下几方面：
1. **工具之间的依赖关系**：部分工具在运行时可能会互相等待，导致扫描任务之间的串行化执行。
2. **资源消耗**：如 `masscan` 进行大规模端口扫描时，可能会消耗大量的 CPU 和网络带宽，导致性能下降。
3. **高并发**：同时运行多个任务时，可能会遇到内存或 CPU 资源的过载，影响扫描速度。

### 贡献
SubDroid 是开源项目，欢迎安全研究人员和开发者参与贡献。您可以提交 Bug 报告、建议或改进功能。我们也鼓励您对工具进行个性化定制和功能扩展。

### License
SubDroid 遵循 MIT License，您可以自由使用、修改和分发此工具，但需遵循许可协议。

---

SubDroid 是一款功能强大且易于使用的子域名枚举与安全扫描工具，能够帮助您高效地发现目标域名的潜在安全问题。但在处理大规模目标时，需要注意并行性带来的性能瓶颈和稳定性问题。
# SubDroid
