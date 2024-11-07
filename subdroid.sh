#!/bin/bash
# 检查是否提供了-h参数
if [[ "$1" == "-h" ]]; then
  echo "Usage: $0 <domain> [output_file]"
  echo ""
  echo "Parameter Description:"
  echo "  <domain>      Required parameter, specifies the domain to be scanned."
  echo "  [output_file] Optional parameter, specifies the output file name, default is combined_output.txt."
  echo ""
  echo "Tool Advantages:"
  echo "  - Automation: Integrates multiple security tools to automate various scanning tasks."
  echo "  - Result Integration: Outputs all results to a specified directory for easy viewing and analysis."
  echo "  - Flexibility: Supports custom output file names."
  echo "  - Extensibility: Allows for additional features and tools to be added as needed."
  exit 0
fi



# 检查是否提供了域名参数
if [ -z "$1" ]; then
  echo "Usage: $0 <domain> [output_file] [-crawl]"
  exit 1
fi

DOMAIN=$1

# 如果提供了第二个参数，则使用该参数作为输出文件名，否则使用默认的 combined_output.txt
if [ -z "$2" ]; then
  OUTPUT_FILE="combined_output.txt"
else
  OUTPUT_FILE="$2"
fi



# 验证是否已经扫描过，防止反复迭代
if [ -d "./result/$DOMAIN" ]; then
  echo "Reset Begin"
  rm -rf "./result/$DOMAIN"
  echo "Already Reset"
  exit 1
fi



# 确保 result 文件夹存在，如果不存在则创建
mkdir -p result/$DOMAIN/SUB

# 设置完整输出路径，将文件放在 result 文件夹下
OUTPUT_PATH="result/$DOMAIN/SUB/$OUTPUT_FILE"

# 清空或创建输出文件
> $OUTPUT_PATH


# 使用 subfinder 获取子域名并追加到输出文件
if ! ./subfinder/subfinder -h &> /dev/null; then
    echo "Need assetfinder"
else
  echo "Running subfinder for domain: $DOMAIN"
  ./subfinder/subfinder -d $DOMAIN -o subfinder_output.txt
  echo "Subfinder output:" >> $OUTPUT_PATH
  cat subfinder_output.txt >> $OUTPUT_PATH
  echo "" >> $OUTPUT_PATH  # 添加一个空行以区分输出
fi 


#与灯塔同一原理的子域名收集装置-assetfinder
if ! ./assetfinder/assetfinder -h  &> /dev/null; then
    echo "Need assetfinder"
else
    ./assetfinder/assetfinder --subs-only $DOMAIN > subdomains.txt
    echo "assetfinder output:" >> $OUTPUT_PATH
    cat subdomains.txt >> $OUTPUT_PATH
    echo "" >> $OUTPUT_PATH
    # 删除冗余的中间输出文件
    rm subdomains.txt
fi
    
rm subfinder_output.txt
echo "#####SUBdomain already -->result/$DOMAIN/SUB######"


# 分别确保域名+ip对应以及纯ip目录存在
mkdir -p result/$DOMAIN/IP/ip
mkdir -p result/$DOMAIN/IP/domain
IP_OUTPUT_PATH="result/$DOMAIN/IP/domain/$OUTPUT_FILE"
IP_OUTPUT_PATH2="result/$DOMAIN/IP/ip/$OUTPUT_FILE"

# 验证dnsx存在以及dnsx逻辑
if ! ./dnsx/dnsx -h &> /dev/null; then
    echo "dnsx not installed"
else
    # 获取纯 IP 并输出到 ip 文件
    ./dnsx/dnsx -l $OUTPUT_PATH -resp -a -aaaa -cname -o ips.txt
    
    input_file="ips.txt"

    echo "Processing file: $input_file"
    echo "Output file path: $IP_OUTPUT_PATH"
    echo "Pure IP file path: $IP_OUTPUT_PATH2"

    # 清除颜色码并提取信息
    sed -e 's/\x1b\[[0-9;]*m//g' -n -e 's/.* \[A\] \[\([0-9.]\+\)\].*/\1/p' "$input_file" > "$IP_OUTPUT_PATH2"
    sed -e 's/\x1b\[[0-9;]*m//g' -n -e 's/^\(.*\) \[A\] \[\([0-9.]\+\)\]/\1:\2/p' "$input_file" > "$IP_OUTPUT_PATH"

    # 检查输出文件是否成功生成
    if [[ -s "$IP_OUTPUT_PATH2" ]]; then
        echo "Pure IP file generated successfully"
    else
        echo "Pure IP file generation failed or is empty"
    fi

    if [[ -s "$IP_OUTPUT_PATH" ]]; then
        echo "Domain:IP file generated successfully"
    else
        echo "Domain:IP file generation failed or is empty"
    fi
    
    # 删除冗余文件
    rm "$input_file"
fi


# 对纯 IP 去重和排序
sort "$IP_OUTPUT_PATH2" | uniq > temp_sorted_ips.txt


# 覆盖原文件
mv temp_sorted_ips.txt "$IP_OUTPUT_PATH2"
# 删除冗余文件
rm temp_sorted_ips.txt
echo "#####IP already --> result/$DOMAIN/IP######"

# ALIVE
mkdir -p "result/$DOMAIN/ALIVE"
if ! ./puredns/puredns -h &> /dev/null; then
   echo "Need puredns"
else
   echo "Sirvive Detect-->puedns:"
   touch ./result/$DOMAIN/ALIVE/pure.txt
   cat $OUTPUT_PATH | ./puredns/puredns resolve --debug > ./result/$DOMAIN/ALIVE/pure.txt
fi
# 探活2
source venv/bin/activate
python3 ./survive/web_scanner.py "./result/$DOMAIN/SUB/$OUTPUT_FILE" "result/$DOMAIN/ALIVE" "$OUTPUT_FILE"
mv report.html result/$DOMAIN/ALIVE
echo "#####ALIVE already finished#####"

cat ./result/$DOMAIN/IP/ip/$OUTPUT_FILE >./tmp.txt
awk -F: '{print $1}' ./result/$DOMAIN/IP/domain/$OUTPUT_FILE > ./tmp.txt

#端口扫描目录
mkdir -p "result/$DOMAIN/PORTS"
PORT_Path="result/$DOMAIN/PORTS"
#端口扫描，只采用masscan，同时字典为未授权高敏各国常用字典
#由于命令需要管理员权限，需要用户自行定义masscan免密码
python3 ./Ports/masscan.py ./result/$DOMAIN/IP/ip/$OUTPUT_FILE ./Ports/ports.txt $PORT_Path
python3 ./Ports/masscan.py ./result/$DOMAIN/SUB/$OUTPUT_FILE ./Ports/ports.txt $PORT_Path



#加入指纹扫描模块 引用子域名目录
mkdir -p "result/$DOMAIN/Finger"
python3 ./f1nger/f1nger.py ./result/$DOMAIN/SUB/$OUTPUT_FILE ./result/$DOMAIN/Finger/$OUTPUT_FILE
python3 ./f1nger/f1nger.py ./result/$DOMAIN/PORTS/open_ports.txt ./result/$DOMAIN/Finger/$OUTPUT_FILE

#激活虚拟化环境+网站截图 功能尚在测试，未配置成功请勿打开
#mkdir -p "./result/$DOMAIN/SHOTS/"
#soursource venv/bin/activate
#python ./EyeWitness/Python/EyeWitness.py -f ./tmp.txt --web -d ./result/$DOMAIN/SHOTS/$OUTPUT_FILE

#漏洞扫描

mkdir -p "result/$DOMAIN/Leak!"
#测试环境是否安装 未安装则会自动重装
./nuclei/nuclei
nuclei -u ./tmp.txt -o ./result/$DOMAIN/Leak/$OUTPUT_FILE

FFUF() {
    count=0
    limit=150

    while IFS= read -r subdomain; do
        echo "Fuzzing directories for $subdomain"
        
        # 使用 ffuf 并将输出重定向到临时文件
        ffuf -u "$subdomain/FUZZ" -w "$directories_file" -o "$subdomain.txt" > /dev/null 2>&1
        
        # 检查输出文件中 Status:200 的数量
        status_200_count=$(grep -c "Status: 200" "$subdomain.txt")
        count=$((count + status_200_count))
        
        # 移动输出文件
        mv "./$subdomain.txt" "./result/$DOMAIN/dir/$subdomain.txt"
        
        # 检查计数是否超过限制
        if [ "$count" -gt "$limit" ]; then
            echo "Status: 200 count exceeded $limit. Terminating scans."
            break
        fi
    done < "$subdomains_file"
}
mkdir -p "result/$DOMAIN/dir"
subdomains_file="result/$DOMAIN/SUB/$OUTPUT_FILE"
directories_file="./dir/dir.txt"


rm -f ./tmp.txt



