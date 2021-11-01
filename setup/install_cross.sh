#!/usr/bin/env bash

MYDIR=$(dirname "$0")
echo "downloading toolchain and raspi libraries"
export URLTCN=https://github.com/kkibria/raspi-toolchain/releases/latest/download/raspi-toolchain.tar.gz
export URLIMG=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip
wget $URLTCN
wget $URLIMG
sudo echo "installing toolchain and raspi libraries"
bash $MYDIR/install_pi_gcc.sh
bash $MYDIR/install_pi_libs.sh
echo 'PATH=/opt/cross-pi-gcc/bin:/opt/cross-pi-gcc/libexec/gcc/arm-linux-gnueabihf/8.3.0:$PATH' >> ~/.bashrc 
sudo ln -s $HOME/rpi/rootfs/lib/arm-linux-gnueabihf /lib
