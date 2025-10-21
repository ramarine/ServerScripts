#!/bin/bash

time_to_measure=60
iend=$((SECONDS + time_to_measure))


if [ "$1" == "--help" ]; then
	echo " bla bla"
	exit 1
fi

if [ -n "$1" ]; then
	filename=$1
	> "$filename"
else 
	filename=$(date +"%d_%b_%Y_%H_%M_%S.csv")
	echo "No file input provided. Generating automatic file called ${filename}"
	> "$filename"
fi

echo "Power(watts) Date" >> "$filename"


while [ $SECONDS -lt $iend ]; do  
  VALUE=$(sudo ipmitool sensor get "Pwr Consumption" | grep "Sensor Reading" | awk '{print $4}')
  NOW=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$VALUE $NOW"
  echo "$VALUE $NOW" >> "$filename"
  sleep 10
done

