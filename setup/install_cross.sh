#!/usr/bin/env bash

MYDIR=$(dirname "$0")
sudo echo "downloading and installing toolchain and raspi libraries"
bash $MYDIR/install_pi_gcc.sh
bash $MYDIR/install_pi_libs.sh
