#!/bin/bash

IMG_BASENAME=2018-04-18-raspbian-stretch-lite
DL_LOCATION="https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2018-04-19/${IMG_BASENAME}.zip"


echo "This script downloads and unzips the Raspbian lite image into the data directory. ~4 GB of space is required."
read -r -p "Continue? [y/n]" do_download

case $do_download in
     [yY][eE][sS]|[yY])
   echo
   echo "Downloading the raspbian lite image."

   SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
   DATA_DIR=$SCRIPT_DIR/../data/
   TMP_DIR=$(mktemp -d)
   CURR_DIR=$(pwd)

   cd $TMP_DIR
   wget $DL_LOCATION

   echo "DONE"
   echo ""

   echo "Inflating and copying to data dir."
   unzip $IMG_BASENAME.zip
   mv $IMG_BASENAME.img $DATA_DIR
   echo "DONE"

   echo "Cleaning up ..."
   rm -rf $TMP_DIR
   echo -n " DONE"

   ;;
     *)
   echo ""
   ;;
esac
