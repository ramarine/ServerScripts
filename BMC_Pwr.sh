#!/bin/bash

# Set default values
filename=""
unit="watts"
time_to_measure=60
poll_interval=10

usage() {
    echo "Usage: $0 [-f filename] [-u unit] [-d duration] [-i interval] [-h]"
    echo "  -f    Output filename (default: auto-generated timestamp)"
    echo "  -u    What unit you want to measure: Watts, Volts, etc. (default: volts)"
    echo "  -d    Duration in seconds (default: 60)"
    echo "  -i    Time interval between consecutive sensor polling (default: 10)"
    echo "  -h    Show this help message"
    echo ""
    exit 0
}

while getopts "f:u:d:i:h" opt; do
    case $opt in
        f)
            filename="$OPTARG"
            ;;
        u)
            unit="$OPTARG"
            ;;
        d)
            time_to_measure="$OPTARG"
            ;;
        i)
            poll_interval="$OPTARG"
            ;;
        h)
            usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done


if [ -z "$filename" ]; then
    filename=$(date +"%d_%b_%Y_%H_%M_%S.csv")
    echo "No file input provided. Generating automatic file called ${filename}"
fi

> "$filename"

echo "Configuration:"
echo "  Output file: $filename"
echo "  Measuring: $unit"
echo "  Duration: $time_to_measure seconds"
echo "  Poll interval: $poll_interval seconds"
echo ""


iend=$((SECONDS + time_to_measure))
mapfile -t SENSORS < <(sudo ipmitool sdr list | grep -i "$unit" | awk -F '|' '{print $1}' | sed 's/^[ \t]*//;s/[ \t]*$//')

# Check if sensors were found
if [ ${#SENSORS[@]} -eq 0 ]; then
    echo "Error: No sensors found matching '$unit'"
    exit 1
fi


HEADER="Timestamp"
for SENSOR in "${SENSORS[@]}"; do
    HEADER="$HEADER,$SENSOR"
done
echo "$HEADER" | tee -a "$filename"


while [ $SECONDS -lt $iend ]; do
    LOOP_START=$SECONDS
    NOW=$(date +"%Y-%m-%d %H:%M:%S")
    LINE="$NOW"

    # Loop through each sensor and get its value
    for SENSOR in "${SENSORS[@]}"; do
        VALUE=$(sudo ipmitool sensor get "$SENSOR" | grep "Sensor Reading" | awk -F ':' '{print $2}')
        LINE="$LINE,$VALUE"
    done
    
    echo "$LINE" | tee -a "$filename"
    
    ELAPSED=$((SECONDS - LOOP_START))
    SLEEP_TIME=$((poll_interval - ELAPSED))
    
    if [ $SLEEP_TIME -gt 0 ]; then
        sleep $SLEEP_TIME
    fi
done

echo ""
echo "Monitoring complete. Data saved to $filename"
