#!/bin/bash

# 默认色温 (6000K 是 hyprsunset 的默认值)
DEFAULT_TEMP=6000
STEP=50  # 每次调整 10K
MAX_TEMP=10000  # 最大色温 (可调整)
MIN_TEMP=1000   # 最小色温 (可调整)

# 存储当前色温的文件
TEMP_FILE="/tmp/hyprsunset_ctl.tmp"

# 如果文件不存在，则使用默认值
if [ ! -f "$TEMP_FILE" ]; then
    echo "$DEFAULT_TEMP" > "$TEMP_FILE"
fi

# 读取当前色温
current_temp=$(cat "$TEMP_FILE")

# 检查参数
if [ "$1" == "-u" ]; then
    # 杀死现有的 hyprsunset 进程
    pkill -f "hyprsunset" || true
    # 增加色温 (+10K)
    new_temp=$((current_temp + STEP))
    if [ $new_temp -gt $MAX_TEMP ]; then
        new_temp=$MAX_TEMP
    fi
    hyprsunset --temperature "$new_temp" &
    echo "$new_temp" > "$TEMP_FILE"
    notify-send "🌡️ 色温调整" "当前色温: ${new_temp}K" -u normal
elif [ "$1" == "-d" ]; then
    # 杀死现有的 hyprsunset 进程
    pkill -f "hyprsunset" || true
    # 降低色温 (-10K)
    new_temp=$((current_temp - STEP))
    if [ $new_temp -lt $MIN_TEMP ]; then
        new_temp=$MIN_TEMP
    fi
    hyprsunset --temperature "$new_temp" &
    echo "$new_temp" > "$TEMP_FILE"
    notify-send "🌡️ 色温调整" "当前色温: ${new_temp}K" -u normal
elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "用法: $0 [-u|-d|-h]"
    echo "  -u    色温 +10K（更冷，偏蓝）"
    echo "  -d    色温 -10K（更暖，偏黄/红）"
    echo "  -h    显示帮助信息"
    exit 0
else
    # 不带参数时，使用上次存储的色温运行
    pkill -f "hyprsunset" || true
    hyprsunset --temperature "$current_temp" &
    notify-send "🌙 夜览模式" "当前色温: ${current_temp}K" -u normal
fi
