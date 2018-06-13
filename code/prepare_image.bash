#!/bin/bash


################################################################################
# Global parameters for configuration. the USB stick file system ID needs to be
# adapted!

# get the file system id with sudo blkid
USB_STICK_FS_ID=8AF2-F643

# Adapt this if needed.
CRON_SCHEDULE="0 6-20/2 * * *"
#CRON_SCHEDULE="*/1 * * * *" # for testing, every 2 minutes

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_IMAGE=${SCRIPT_DIR}/../data/2018-04-18-raspbian-stretch-lite.img
RPI_TEMPLATE_DIR=${SCRIPT_DIR}/rpi/
RPI_MOUNT_DIR=/mnt/root
RPI_BOOT_MOUNT_DIR=/mnt/boot

# Adjust this to your setup. If there is enough space available, use
# TMPDIR=$(mktemp -d)
TMPDIR=/home/merops/pi/tmp/img
#
################################################################################


################################################################################
# usage
usage()
{
    echo "Creates an image for Raspberry Pi image acquisition."
    echo ""
    echo "Usage: $0 -h hostname -o output_dir"
    echo ""
    echo "-h hostname: a hostname for the Rasbperry Pi, e.g. cam1."
    echo ""
    echo "-d output_dir: Directory where the output image should be written to."
    echo "               The image name is hostname.img."
    exit 1
}
#
################################################################################


###############################################################################
# defined(variable_name) 
# Checks if variable variable_name is defined.
#
# Returns 0 if not and length of variable otherwise.

set +H
function defined() {
    [[ ${!1-X} == ${!1-Y} ]]
}
#
################################################################################


################################################################################
# Command line arguments parsing
while getopts ":h:d:" o; do
    case ${o} in
	h)
	    h=${OPTARG}
	    ;;
	d)
	    d=${OPTARG}
	    ;;
	*)
	    usage
	    ;;
    esac
done
shift $((OPTIND-1))

if ! defined d ; then
    usage
fi
if ! defined h ; then
    usage
fi
	  
HOSTNAME=$h
OUTPUT_DIR=$d

#
################################################################################


################################################################################
# Prepare new image
mkdir -p $TMPDIR

echo -n "Copying template image ..."
PI_IMAGE=$TMPDIR/raspbian.img
cp $TEMPLATE_IMAGE $PI_IMAGE
echo " DONE"

echo "Mounting the PI file system."
sudo bash -c "mkdir -p $RPI_MOUNT_DIR"
sudo bash -c "mount -o offset=50331648 -t ext4 $PI_IMAGE $RPI_MOUNT_DIR"
echo "Customizing image ..."
echo ""
# Hostame
echo $HOSTNAME | sudo tee $RPI_MOUNT_DIR/etc/hostname

# Set up cron job
echo "$CRON_SCHEDULE   root    /root/acquire_image.sh" |sudo tee -a $RPI_MOUNT_DIR/etc/crontab

# Add udev rule for auto copy on mount
echo "KERNEL==\"sd*\",ACTION==\"add\" , ENV{ID_FS_UUID}==\"${USB_STICK_FS_ID}\",RUN=\"/root/transfer_images.sh %k add\"" | sudo tee $RPI_MOUNT_DIR/etc/udev/rules.d/90-local.rules

# Restart udev to have write access to root file system
echo "!/bin/sh -e" |sudo tee $RPI_MOUNT_DIR/etc/rc.local
echo "/etc/init.d/udev restart" |sudo tee -a $RPI_MOUNT_DIR/etc/rc.local
echo "exit 0" |sudo tee -a $RPI_MOUNT_DIR/etc/rc.local

# Copy image handling files
sudo cp $RPI_TEMPLATE_DIR/root/acquire_image.sh $RPI_MOUNT_DIR/root/
sudo chmod +x $RPI_MOUNT_DIR/root/acquire_image.sh

sudo cp $RPI_TEMPLATE_DIR/root/transfer_images.sh $RPI_MOUNT_DIR/root/
sudo chmod +x $RPI_MOUNT_DIR/root/transfer_images.sh
sudo umount $RPI_MOUNT_DIR

# Camera setup
echo "Mounting the PI boot file system."
sudo bash -c "mkdir -p $RPI_BOOT_MOUNT_DIR"
sudo bash -c "mount -o offset=4194304 -t vfat $PI_IMAGE $RPI_BOOT_MOUNT_DIR"
 
echo "start_x=1" | sudo tee -a $RPI_BOOT_MOUNT_DIR/config.txt
echo "gpu_mem=128" | sudo tee -a $RPI_BOOT_MOUNT_DIR/config.txt
sudo umount $RPI_BOOT_MOUNT_DIR
echo "DONE"
echo ""

# Clean up
echo -n "Copying temporary image and cleaning up ..."

cp $PI_IMAGE $OUTPUT_DIR/$HOSTNAME.img
rm -rf $TMPDIR
echo " DONE"

#
################################################################################
