#!/usr/bin/env bash

MYDIR=$(dirname "$0")
sudo echo "downloading and installing toolchain and raspi libraries"
export URLTCN=https://github.com/kkibria/raspi-toolchain/releases/latest/download/raspi-toolchain.tar.gz
export URLIMG=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip
bash $MYDIR/install_pi_gcc.sh
bash $MYDIR/install_pi_libs.sh
