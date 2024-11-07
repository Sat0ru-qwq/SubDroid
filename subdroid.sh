#!/bin/bash
# ����Ƿ��ṩ��-h����
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



# ����Ƿ��ṩ����������
if [ -z "$1" ]; then
  echo "Usage: $0 <domain> [output_file] [-crawl]"
  exit 1
fi

DOMAIN=$1

# ����ṩ�˵ڶ�����������ʹ�øò�����Ϊ����ļ���������ʹ��Ĭ�ϵ� combined_output.txt
if [ -z "$2" ]; then
  OUTPUT_FILE="combined_output.txt"
else
  OUTPUT_FILE="$2"
fi



# ��֤�Ƿ��Ѿ�ɨ�������ֹ��������
if [ -d "./result/$DOMAIN" ]; then
  echo "Reset Begin"
  rm -rf "./result/$DOMAIN"
  echo "Already Reset"
  exit 1
fi



# ȷ�� result �ļ��д��ڣ�����������򴴽�
mkdir -p result/$DOMAIN/SUB

# �����������·�������ļ����� result �ļ�����
OUTPUT_PATH="result/$DOMAIN/SUB/$OUTPUT_FILE"

# ��ջ򴴽�����ļ�
> $OUTPUT_PATH


# ʹ�� subfinder ��ȡ��������׷�ӵ�����ļ�
if ! ./subfinder/subfinder -h &> /dev/null; then
    echo "Need assetfinder"
else
  echo "Running subfinder for domain: $DOMAIN"
  ./subfinder/subfinder -d $DOMAIN -o subfinder_output.txt
  echo "Subfinder output:" >> $OUTPUT_PATH
  cat subfinder_output.txt >> $OUTPUT_PATH
  echo "" >> $OUTPUT_PATH  # ���һ���������������
fi 


#�����ͬһԭ����������ռ�װ��-assetfinder
if ! ./assetfinder/assetfinder -h  &> /dev/null; then
    echo "Need assetfinder"
else
    ./assetfinder/assetfinder --subs-only $DOMAIN > subdomains.txt
    echo "assetfinder output:" >> $OUTPUT_PATH
    cat subdomains.txt >> $OUTPUT_PATH
    echo "" >> $OUTPUT_PATH
    # ɾ��������м�����ļ�
    rm subdomains.txt
fi
    
rm subfinder_output.txt
echo "#####SUBdomain already -->result/$DOMAIN/SUB######"


# �ֱ�ȷ������+ip��Ӧ�Լ���ipĿ¼����
mkdir -p result/$DOMAIN/IP/ip
mkdir -p result/$DOMAIN/IP/domain
IP_OUTPUT_PATH="result/$DOMAIN/IP/domain/$OUTPUT_FILE"
IP_OUTPUT_PATH2="result/$DOMAIN/IP/ip/$OUTPUT_FILE"

# ��֤dnsx�����Լ�dnsx�߼�
if ! ./dnsx/dnsx -h &> /dev/null; then
    echo "dnsx not installed"
else
    # ��ȡ�� IP ������� ip �ļ�
    ./dnsx/dnsx -l $OUTPUT_PATH -resp -a -aaaa -cname -o ips.txt
    
    input_file="ips.txt"

    echo "Processing file: $input_file"
    echo "Output file path: $IP_OUTPUT_PATH"
    echo "Pure IP file path: $IP_OUTPUT_PATH2"

    # �����ɫ�벢��ȡ��Ϣ
    sed -e 's/\x1b\[[0-9;]*m//g' -n -e 's/.* \[A\] \[\([0-9.]\+\)\].*/\1/p' "$input_file" > "$IP_OUTPUT_PATH2"
    sed -e 's/\x1b\[[0-9;]*m//g' -n -e 's/^\(.*\) \[A\] \[\([0-9.]\+\)\]/\1:\2/p' "$input_file" > "$IP_OUTPUT_PATH"

    # �������ļ��Ƿ�ɹ�����
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
    
    # ɾ�������ļ�
    rm "$input_file"
fi


# �Դ� IP ȥ�غ�����
sort "$IP_OUTPUT_PATH2" | uniq > temp_sorted_ips.txt


# ����ԭ�ļ�
mv temp_sorted_ips.txt "$IP_OUTPUT_PATH2"
# ɾ�������ļ�
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
# ̽��2
source venv/bin/activate
python3 ./survive/web_scanner.py "./result/$DOMAIN/SUB/$OUTPUT_FILE" "result/$DOMAIN/ALIVE" "$OUTPUT_FILE"
mv report.html result/$DOMAIN/ALIVE
echo "#####ALIVE already finished#####"

cat ./result/$DOMAIN/IP/ip/$OUTPUT_FILE >./tmp.txt
awk -F: '{print $1}' ./result/$DOMAIN/IP/domain/$OUTPUT_FILE > ./tmp.txt

#�˿�ɨ��Ŀ¼
mkdir -p "result/$DOMAIN/PORTS"
PORT_Path="result/$DOMAIN/PORTS"
#�˿�ɨ�裬ֻ����masscan��ͬʱ�ֵ�Ϊδ��Ȩ�������������ֵ�
#����������Ҫ����ԱȨ�ޣ���Ҫ�û����ж���masscan������
python3 ./Ports/masscan.py ./result/$DOMAIN/IP/ip/$OUTPUT_FILE ./Ports/ports.txt $PORT_Path
python3 ./Ports/masscan.py ./result/$DOMAIN/SUB/$OUTPUT_FILE ./Ports/ports.txt $PORT_Path



#����ָ��ɨ��ģ�� ����������Ŀ¼
mkdir -p "result/$DOMAIN/Finger"
python3 ./f1nger/f1nger.py ./result/$DOMAIN/SUB/$OUTPUT_FILE ./result/$DOMAIN/Finger/$OUTPUT_FILE
python3 ./f1nger/f1nger.py ./result/$DOMAIN/PORTS/open_ports.txt ./result/$DOMAIN/Finger/$OUTPUT_FILE

#�������⻯����+��վ��ͼ �������ڲ��ԣ�δ���óɹ������
#mkdir -p "./result/$DOMAIN/SHOTS/"
#soursource venv/bin/activate
#python ./EyeWitness/Python/EyeWitness.py -f ./tmp.txt --web -d ./result/$DOMAIN/SHOTS/$OUTPUT_FILE

#©��ɨ��

mkdir -p "result/$DOMAIN/Leak!"
#���Ի����Ƿ�װ δ��װ����Զ���װ
./nuclei/nuclei
nuclei -u ./tmp.txt -o ./result/$DOMAIN/Leak/$OUTPUT_FILE

FFUF() {
    count=0
    limit=150

    while IFS= read -r subdomain; do
        echo "Fuzzing directories for $subdomain"
        
        # ʹ�� ffuf ��������ض�����ʱ�ļ�
        ffuf -u "$subdomain/FUZZ" -w "$directories_file" -o "$subdomain.txt" > /dev/null 2>&1
        
        # �������ļ��� Status:200 ������
        status_200_count=$(grep -c "Status: 200" "$subdomain.txt")
        count=$((count + status_200_count))
        
        # �ƶ�����ļ�
        mv "./$subdomain.txt" "./result/$DOMAIN/dir/$subdomain.txt"
        
        # �������Ƿ񳬹�����
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



