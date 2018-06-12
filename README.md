# Overview

The repository provides tools to set up multiple Raspberry Pi's for
autonomous image acquisition without a network connection. When a USB
stick is inserted, the images are copied to the subfolder /hostname/.

# Setup
* Clone the repository
* Run `download_image.bash` to download the Rasbian lite image
* Adjust the global parameters in `prepare_image.bash` to fit your USB stick file system id and image acquisition interval. Get the file system id with `sudo blkid`.
* Run `prepare_image.bash` to create your host image. E.g. `./prepare_image.bash -h cam1 -d /tmp/` writes the image with hostname cam1 to the `/tmp/` dir.
* Write the image to the sd card: `sudo dd if=cam1.img iflag=direct of=/dev/sdd bs=4M`.
