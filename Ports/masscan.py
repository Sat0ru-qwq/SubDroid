# -*- coding: utf-8 -*-
import os
import argparse
import re

# 创建 ArgumentParser 对象
parser = argparse.ArgumentParser(description="Masscan Port Scanner with Custom Ports")

# 添加 IP 文件参数
parser.add_argument('ip_file', type=str, help="Path to the file containing the list of IP addresses")
# 添加端口文件参数
parser.add_argument('port_file', type=str, help="Path to the file containing the list of ports")
# 添加输出路径参数
parser.add_argument('output_dir', type=str, help="Path to the directory where output files will be saved")

# 解析命令行参数
args = parser.parse_args()

# 创建输出目录（如果不存在）
if not os.path.exists(args.output_dir):
    os.makedirs(args.output_dir)

# 读取端口文件并将其格式化为逗号分隔的字符串
with open(args.port_file, 'r') as f:
    ports = f.read().strip().replace('\n', ',')

# 运行 masscan 命令并将结果保存到指定路径
masscan_results_path = os.path.join(args.output_dir, 'masscan_results.txt')
masscan_command = f"sudo masscan -iL {args.ip_file} -p{ports} --rate=50 -oG {masscan_results_path}"
print("Executing command:", masscan_command)
os.system(masscan_command)

# 打开并读取 masscan 结果文件
with open(masscan_results_path, 'r') as f:
    results = f.readlines()

# 创建一个集合用于存储提取的唯一 IP 地址
ip_ports = []

# 遍历每一行 masscan 结果
for line in results:
    # 使用正则表达式匹配 'Host' 后的 IP 和 'Ports' 后的端口号
    match = re.search(r'Host: ([\d\.]+).*Ports: (\d+)/open', line)
    if match:
        ip = match.group(1)    # 提取 IP
        port = match.group(2)  # 提取端口
        
        # 将 IP 和端口添加到列表中，每行格式为 ip:port
        ip_ports.append(f"{ip}:{port}")

# 将提取的 IP 和端口写入指定路径的文件，每行一个 ip:port
open_ports_path = os.path.join(args.output_dir, 'open_ports.txt')
with open(open_ports_path, 'w') as f:
    for ip_port in ip_ports:
        f.write(ip_port + "\n")

# 打印提取的开放端口
print("Extracted IPs and ports (one per line):")
for ip_port in ip_ports:
    print(ip_port)
