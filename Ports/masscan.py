# -*- coding: utf-8 -*-
import os
import argparse
import re

# ���� ArgumentParser ����
parser = argparse.ArgumentParser(description="Masscan Port Scanner with Custom Ports")

# ��� IP �ļ�����
parser.add_argument('ip_file', type=str, help="Path to the file containing the list of IP addresses")
# ��Ӷ˿��ļ�����
parser.add_argument('port_file', type=str, help="Path to the file containing the list of ports")
# ������·������
parser.add_argument('output_dir', type=str, help="Path to the directory where output files will be saved")

# ���������в���
args = parser.parse_args()

# �������Ŀ¼����������ڣ�
if not os.path.exists(args.output_dir):
    os.makedirs(args.output_dir)

# ��ȡ�˿��ļ��������ʽ��Ϊ���ŷָ����ַ���
with open(args.port_file, 'r') as f:
    ports = f.read().strip().replace('\n', ',')

# ���� masscan �����������浽ָ��·��
masscan_results_path = os.path.join(args.output_dir, 'masscan_results.txt')
masscan_command = f"sudo masscan -iL {args.ip_file} -p{ports} --rate=50 -oG {masscan_results_path}"
print("Executing command:", masscan_command)
os.system(masscan_command)

# �򿪲���ȡ masscan ����ļ�
with open(masscan_results_path, 'r') as f:
    results = f.readlines()

# ����һ���������ڴ洢��ȡ��Ψһ IP ��ַ
ip_ports = []

# ����ÿһ�� masscan ���
for line in results:
    # ʹ��������ʽƥ�� 'Host' ��� IP �� 'Ports' ��Ķ˿ں�
    match = re.search(r'Host: ([\d\.]+).*Ports: (\d+)/open', line)
    if match:
        ip = match.group(1)    # ��ȡ IP
        port = match.group(2)  # ��ȡ�˿�
        
        # �� IP �Ͷ˿���ӵ��б��У�ÿ�и�ʽΪ ip:port
        ip_ports.append(f"{ip}:{port}")

# ����ȡ�� IP �Ͷ˿�д��ָ��·�����ļ���ÿ��һ�� ip:port
open_ports_path = os.path.join(args.output_dir, 'open_ports.txt')
with open(open_ports_path, 'w') as f:
    for ip_port in ip_ports:
        f.write(ip_port + "\n")

# ��ӡ��ȡ�Ŀ��Ŷ˿�
print("Extracted IPs and ports (one per line):")
for ip_port in ip_ports:
    print(ip_port)
