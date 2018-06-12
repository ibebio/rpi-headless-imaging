#!/bin/bash

dest_dir=/home/pi/images/
img="$(hostname)_$(date +%F_%H:%M).png"


mkdir -p ${dest_dir}

/usr/bin/raspistill -o ${dest_dir}/${img}
