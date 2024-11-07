# -*- coding: utf-8 -*-
import argparse
import subprocess
import os
import re

def clean_output(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    # Remove ANSI color codes
    content_cleaned = re.sub(r'\x1b\[[0-9;]*m', '', content)

    # Remove blocks containing "Time Used: 0 √Î"

    # Write the cleaned content back to the file
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(content_cleaned)


parser = argparse.ArgumentParser()  # Correctly instantiate the ArgumentParser
parser.add_argument('file_path', type=str, help='Path to the input file')
parser.add_argument('out_path', type=str, help='Path to the output file')


args = parser.parse_args()
file_path = args.file_path
out_path = args.out_path


if not os.path.exists(out_path):
    with open(out_path, 'w', encoding='utf-8') as output_file:
        output_file.write('')  


with open(file_path, 'r', encoding='utf-8') as file, open(out_path, 'a', encoding='utf-8') as output_file:
    for line in file:
        parameter = line.strip() 
        parameter = f"http://{parameter}"
        if parameter:
            try:
                subprocess.run(['python3', './f1nger/TideFinger.py', '-u', parameter], stdout=output_file, stderr=output_file, check=True)
            except subprocess.CalledProcessError as e:
                output_file.write(f"Error running command with parameter {parameter}: {e}\n")


clean_output(out_path)

with open(file_path, 'r', encoding='utf-8') as file:
    lines = file.readlines()


modified_lines = []
for line in lines:
    parameter = line.strip()
    if parameter:
        modified_parameter = f"http://{parameter}"
        modified_lines.append(modified_parameter + '\n')


with open(file_path, 'w', encoding='utf-8') as file:
    file.writelines(modified_lines)