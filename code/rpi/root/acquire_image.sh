#!/bin/bash

dest_dir=/home/pi/images/
img="$(hostname)_$(date +%F_%H_%M).jpg"
tmpfile=/tmp/image.jpg

mkdir -p ${dest_dir}

/usr/bin/raspistill -n -r -q 95 -o $tmpfile
mv $tmpfile ${dest_dir}/${img}
