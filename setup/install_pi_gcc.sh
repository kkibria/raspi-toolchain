#!/usr/bin/env bash

wget $URLTCN
TAR_GZ=$(basename -- "$URLTCN")
sudo tar xfz $TAR_GZ --strip-components=1 -C /opt
rm $TAR_GZ