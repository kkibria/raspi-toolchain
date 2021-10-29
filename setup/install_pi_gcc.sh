#!/usr/bin/env bash

TAR_GZ=$(basename -- "$URLTCN")
sudo tar xfz $TAR_GZ --strip-components=1 -C /opt