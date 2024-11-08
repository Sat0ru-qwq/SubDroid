#!/usr/bin/env python
# coding=utf-8
  ################
 #   AabyssZG   #
################

import _thread
from enum import Enum
import os
import time
from bs4 import BeautifulSoup

import Generate_Report

import requests, sys, random
from tqdm import tqdm
from typing import Optional, Tuple
from termcolor import cprint
from requests.compat import json
import requests.packages.urllib3
requests.packages.urllib3.disable_warnings()

class EServival(Enum):
    REJECT = -1
    SURVIVE = 1
    DIED = 0

reportData = []

ua = [
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.129 Safari/537.36,Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36",
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.129 Safari/537.36,Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.17 Safari/537.36",
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.129 Safari/537.36,Mozilla/5.0 (X11; NetBSD) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.116 Safari/537.36",
      "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML like Gecko) Chrome/44.0.2403.155 Safari/537.36",
      "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27",
      "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:23.0) Gecko/20130406 Firefox/23.0",
      "Opera/9.80 (Windows NT 5.1; U; zh-sg) Presto/2.9.181 Version/12.00"]

def logo():
    logo0 = r'''
              ╦ ╦┌─┐┌┐              
              ║║║├┤ ├┴┐             
              ╚╩╝└─┘└─┘             
╔═╗┬ ┬┬─┐┬  ┬┬┬  ┬┌─┐┬  ╔═╗┌─┐┌─┐┌┐┌
╚═╗│ │├┬┘└┐┌┘│└┐┌┘├─┤│  ╚═╗│  ├─┤│││
╚═╝└─┘┴└─ └┘ ┴ └┘ ┴ ┴┴─┘╚═╝└─┘┴ ┴┘└┘
             Version: 1.11
Author: 曾哥(@AabyssZG) && jingyuexing
 Whoami: https://github.com/AabyssZG
'''
    print(logo0)

# 修改 file_init 函数
def file_init(output_dir, output_file):
    # 确保输出目录存在
    os.makedirs(output_dir, exist_ok=True)
    
    # 新建正常目标导出TXT
    f1 = open(os.path.join(output_dir, f"output_{output_file}"), "wb+")
    f1.close()
    # 新建其他报错导出TXT
    f2 = open(os.path.join(output_dir, f"outerror_{output_file}"), "wb+")
    f2.close()
    # 创建 .data 目录
    data_dir = os.path.join(output_dir, ".data")
    os.makedirs(data_dir, exist_ok=True)
    report = open(os.path.join(data_dir, "report.json"), "w")
    report.close()

# 修改 scanLogger 函数
def scanLogger(result:Tuple[EServival,Optional[int],str,int,str], output_dir, output_file):
    (status,code,url,length,title) = result
    if status == EServival.SURVIVE:
        cprint(f"[+] 状态码为: {code} 存活URL为: {url} 页面长度为: {length} 网页标题为: {title}","red")
    if(status == EServival.DIED):
        cprint(f"[-] 状态码为: {code} 无法访问URL为: {url} ","yellow")
    if(status == EServival.REJECT):
        cprint(f"[-] URL为 {url} 的目标积极拒绝请求，予以跳过！", "magenta")
    
    if(status == EServival.SURVIVE):
        fileName = os.path.join(output_dir, f"output_{output_file}")
    elif(status == EServival.DIED):
        fileName = os.path.join(output_dir, f"outerror_{output_file}")
    if(status == EServival.SURVIVE or status == EServival.DIED):
        with open(file=fileName, mode="a") as file4:
            file4.write(f"[{code}]  {url}\n")
    collectionReport(result)

def survive(url:str,proxies:dict):
    try:
        header = {"User-Agent": random.choice(ua)}
        requests.packages.urllib3.disable_warnings()
        r = requests.get(url=url, headers=header, proxies=proxies, timeout=10, verify=False)  # 设置超时10秒
        soup = BeautifulSoup(r.content, 'html.parser')
        if soup.title == None:
            title = "Null"
        else:
            title = str(soup.title.string)
    except Exception:
        title = str("error")
        cprint("[-] URL为 " + url + " 的目标积极拒绝请求，予以跳过！", "magenta")
        return (EServival.REJECT,0,url,0,title)
    if r.status_code == 200 or r.status_code == 403:
        return (EServival.SURVIVE,r.status_code,url,len(r.content),title)
    else:
        title = str("error")
        return (EServival.DIED,r.status_code,url,0,title)

def collectionReport(data):
    global reportData
    (status,statusCode,url,length,title) = data
    state = ""
    if status == EServival.DIED:
        state = "deaed"
        titlel = ""
    elif status == EServival.REJECT:
        state = "reject"
        titlel = ""
    elif status == EServival.SURVIVE:
        state = "servival"
        titlel = f"{title}"
    reportData.append({
        "url":url,
        "status":state,
        "statusCode":statusCode,
        "title":titlel
    })

# 修改 dumpReport 函数
def dumpReport(output_dir):
    with open(os.path.join(output_dir, ".data", "report.json"), encoding="utf-8", mode="w") as file:
        file.write(json.dumps(reportData))

def getTask(filename=""):
    if(filename != ""):
        try:
            with open(file=filename,mode="r") as file:
                for url in file:
                    yield url.strip()
        except Exception:
            with open(file=filename,mode="r",encoding='utf-8') as file:
                for url in file:
                    yield url.strip()

# 修改 end 函数
def end(output_dir, output_file):
    count_out = len(open(os.path.join(output_dir, f"output_{output_file}"), 'r').readlines())
    if count_out >= 1:
        print('\n')
        cprint(f"[+][+][+] 发现目标TXT有存活目标，已经导出至 {os.path.join(output_dir, f'output_{output_file}')} ，共 {count_out} 行记录\n","red")
    count_error = len(open(os.path.join(output_dir, f"outerror_{output_file}"), 'r').readlines())
    if count_error >= 1:
        cprint(f"[+][-][-] 发现目标TXT有错误目标，已经导出至 {os.path.join(output_dir, f'outerror_{output_file}')} ，共行{count_error}记录\n","red")

def main():
    logo()
    
    # 从命令行参数获取目标文件名、输出目录和输出文件名
    if len(sys.argv) < 4:
        print("Usage: python3 web_scanner.py <target_file> <output_directory> <output_file>")
        sys.exit(1)
    
    txt_name = sys.argv[1]
    output_dir = sys.argv[2]
    output_file = sys.argv[3]
    
    file_init(output_dir, output_file)
    
    dir_name = ""  # 可以根据需要修改
    proxy_text = ""  # 可以根据需要修改
    if proxy_text:
        proxies = {
        "http": "http://%(proxy)s/" % {'proxy': proxy_text},
        "https": "http://%(proxy)s/" % {'proxy': proxy_text}
        }
        cprint(f"================检测代理可用性中================", "cyan")
        testurl = "https://www.baidu.com/"
        headers = {"User-Agent": "Mozilla/5.0"}  # 响应头
        try:
            requests.packages.urllib3.disable_warnings()
            res = requests.get(testurl, timeout=10, proxies=proxies, verify=False, headers=headers)
            print(res.status_code)
            # 发起请求,返回响应码
            if res.status_code == 200:
                print("GET www.baidu.com 状态码为:" + str(res.status_code))
                cprint(f"[+] 代理可用，马上执行！", "cyan")
        except KeyboardInterrupt:
            print("Ctrl + C 手动终止了进程")
            sys.exit()
        except:
            cprint(f"[-] 代理不可用，请更换代理！", "magenta")
            sys.exit()
    else:
        proxies = {}
    cprint("================开始读取目标TXT并批量测试站点存活================","cyan")
    # 读取目标TXT
    for url in getTask(txt_name):
        if((':443' in url) and ('://' not in url)):
            url = url.replace(":443","")
            url = f"https://{url}"
        elif('://' not in url):
            url = f"http://{url}"
        if str(url[-1]) != "/":
            url = url + "/"
        if (dir_name != "") and (str(dir_name[0]) == "/"):
            url = url + dir_name[1:]
        else:
            url = url + dir_name
        cprint(f"[.] 正在检测目标URL " + url,"cyan")
        try:
            _thread.start_new_thread(lambda url: scanLogger(survive(url,proxies), output_dir, output_file), (url, ))
            time.sleep(1.5)
        except KeyboardInterrupt:
            print("Ctrl + C 手动终止了进程")
            sys.exit()
    time.sleep(3)
    dumpReport(output_dir)
    end(output_dir, output_file)
    input_file= os.path.join(output_dir, ".data/report.json")
    Generate_Report.generaterReport(input_file)
    sys.exit()

if __name__ == '__main__':
    main()