#!/bin/bash

KERNEL=$1
ACTION=$2

case "$ACTION" in
    add)
	mount  /dev/$KERNEL /mnt/
	mkdir -p /mnt/$(hostname)
	cp /home/pi/images/*.png /mnt/$(hostname)
        cp /home/pi/images/*.jpg /mnt/$(hostname)
        rm /home/pi/images/*.png
        rm /home/pi/images/*.jpg
	echo "$(hostname) $(date +%F_%H_%M)" >> /mnt/$(hostname)/copylog.txt
	mkdir -p /mnt/$(hostname)/syslog/
	cp /var/log/syslog /mnt/$(hostname)/syslog/syslog.$(date +%F_%H_%M)
	umount /mnt/
      ;;
    # remove)
    #	umount $DEVNAME
    #  ;;
esac
