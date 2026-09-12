#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

get_temp() {
    local model="$1"
    # -il ignores case and finds the partial string match dynamically
    local model_path=$(grep -il "$model" /sys/class/hwmon/hwmon*/device/model 2>/dev/null | head -n 1)

    if [ -n "$model_path" ]; then
        local hwmon_dir=$(dirname "$(dirname "$model_path")")
        if [ -f "$hwmon_dir/temp1_input" ]; then
            local raw_temp=$(cat "$hwmon_dir/temp1_input")
            awk -v t="$raw_temp" 'BEGIN {printf "%.0f", t/1000}'
        else
            printf "N/A"
        fi
    else
        printf "N/A"
    fi
}

case "$1" in
    12TB) get_temp "HUH721212ALE601" ;;
    10TB) get_temp "HUH721010ALE601" ;;
    8TB)  get_temp "WD80EAZZ" ;;  # Shortened to the core model ID
    4TB)  get_temp "WD40EZRZ" ;;  # Shortened to the core model ID
    *)    printf "0" ;;
esac
