#!/usr/bin/env bash

ZIP=$(basename -- "$URLIMG")
IMG=${ZIP%.*}.img
MNT="raspios"

unzip $ZIP
fdisk -lu $IMG
# Disk 2021-05-07-raspios-buster-armhf-lite.img: 1.76 GiB, 1874853888 bytes, 3661824 sectors
# Units: sectors of 1 * 512 = 512 bytes
# Sector size (logical/physical): 512 bytes / 512 bytes
# I/O size (minimum/optimal): 512 bytes / 512 bytes
# Disklabel type: dos
# Disk identifier: 0x9730496b

# Device                                    Boot  Start     End Sectors  Size Id Type
# 2021-05-07-raspios-buster-armhf-lite.img1        8192  532479  524288  256M  c W95 FAT32 (LBA)
# 2021-05-07-raspios-buster-armhf-lite.img2      532480 3661823 3129344  1.5G 83 Linux
# mkdir -p $MNT/pi-sd-1
mkdir -p $MNT/pi-sd-2
# sudo mount -o loop,offset=4194304,sizelimit=268435456 $IMG $MNT/pi-sd-1
sudo mount -o loop,offset=272629760 $IMG $MNT/pi-sd-2

mkdir $HOME/rpi
pushd $MNT/pi-sd-2/
rsync -vR --progress -rl --delete-after --safe-links {lib,usr,etc/ld.so.conf.d,opt/vc/lib} $HOME/rpi/rootfs
popd
# sudo umount $MNT/pi-sd-1
sudo umount $MNT/pi-sd-2
rm -rf $MNT
rm $IMG
