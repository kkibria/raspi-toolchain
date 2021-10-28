#!/usr/bin/env bash

URL=https://github.com/kkibria/raspi-toolchain/releases/latest/download/raspi-toolchain.tar.gz
wget $URL
TAR_GZ=$(basename -- "$URL")
tar xfz $TAR_GZ --strip-components=1 -C /opt
rm $TAR_GZ