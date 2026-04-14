import pandas as pd
import sys

def format_data(file_path):
    data = {}
    with open(file_path, 'r') as fh:
        for line in fh:
            tmp = line.strip().split("\t")
            a = (tmp[0], tmp[1], tmp[2], tmp[3], tmp[4])
            data[a] = tmp[5]
    return data

def query_data(data, chr, start, end, type):
    # 过滤数据以查找匹配的行
    result = data[(data["Chromosome"] == chr) &
                  (data["Start"] == start) &
                  (data["End"] == end) &
                  (data["Type"] == type)]
    # 返回结果
    if result.empty:
        return "No matching rows found."
    else:
        return result["Value"].values

# 主程序
if __name__ == "__main__":
    data = format_data(sys.argv[1])

    with open(sys.argv[2], 'r') as fh:
        for line in fh:
            tmp = line.strip().split("\t")
            seek = (tmp[0], tmp[1], tmp[2], tmp[3], tmp[4])
            if seek in data:
                print(f"{line.strip()}\t{data[seek]}")
