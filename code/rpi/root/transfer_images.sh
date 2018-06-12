#!/bin/bash

KERNEL=$1
ACTION=$2

case "$ACTION" in
    add)
	mount  /dev/$KERNEL /mnt/
	mkdir -p /mnt/$(hostname)
	mv /home/pi/images/*.png /mnt/$(hostname)
	echo "$(hostname) $(date +%F_%H:%M)" >> /mnt/$(hostname)/copylog.txt
	mkdir -p /mnt/$(hostname)/syslog/
	cp /var/log/syslog /mnt/$(hostname)/syslog/syslog.$(date +%F_%H:%M)
	umount /mnt/
      ;;
    # remove)
    #	umount $DEVNAME
    #  ;;
esac
