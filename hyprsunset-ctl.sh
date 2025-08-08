#!/bin/bash

# 配置文件路径
TEMP_FILE="/tmp/hyprsunset_current_temp"
DEFAULT_TEMP=6000  # 默认色温值
STEP=50            # 调整步长

# 显示中文帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo "使用 hyprsunset 控制屏幕色温"
    echo
    echo "选项:"
    echo "  -u, --u     色温升高 50K"
    echo "  -d, --d     色温降低 50K"
    echo "  -s TEMP     直接设置色温值 (如: 4500)"
    echo "  -h, --help  显示此帮助信息"
    echo
    echo "无参数时应用上次保存的色温值"
}

# 处理参数
OPERATION="apply"
SET_TEMP=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|--u) 
            OPERATION="up"
            shift
            ;;
        -d|--d) 
            OPERATION="down"
            shift
            ;;
        -s)
            if [[ -n $2 ]] && [[ $2 =~ ^[0-9]+$ ]]; then
                SET_TEMP=$2
                OPERATION="set"
                shift 2
            else
                echo "错误: -s 参数后需要指定有效的色温值"
                show_help
                exit 1
            fi
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "无效选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 创建/读取临时文件
if [[ ! -f "$TEMP_FILE" ]]; then
    echo "$DEFAULT_TEMP" > "$TEMP_FILE"
fi
CURRENT_TEMP=$(<"$TEMP_FILE")

# 计算新色温值
case "$OPERATION" in
    up)
        NEW_TEMP=$((CURRENT_TEMP + STEP))
        NOTIFY_TYPE="adjust"
        ;;
    down)
        NEW_TEMP=$((CURRENT_TEMP - STEP))
        NOTIFY_TYPE="adjust"
        ;;
    set)
        NEW_TEMP=$SET_TEMP
        NOTIFY_TYPE="enable"
        ;;
    apply)
        NEW_TEMP=$CURRENT_TEMP
        NOTIFY_TYPE="enable"
        ;;
esac

# 保存新色温值
echo "$NEW_TEMP" > "$TEMP_FILE"

# 终止现有 hyprsunset 进程
pkill -x hyprsunset || true

# 应用新色温并后台运行
hyprsunset -t "$NEW_TEMP" &> /dev/null &

# 根据不同操作类型发送不同通知
case "$NOTIFY_TYPE" in
    enable)
        notify-send "🌙 夜览模式已启用" "当前色温: ${NEW_TEMP}K" -u normal
        ;;
    adjust)
        notify-send "🌡️ 色温已调整" "当前色温: ${NEW_TEMP}K" -u normal
        ;;
esac

exit 0
