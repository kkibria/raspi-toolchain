#!/usr/bin/env bash

docker build -f Dockerfile --network=host -t gcc9-rpi-zero .
CONTAINER_ID=$(docker create gcc9-rpi-zero)
docker cp $CONTAINER_ID:/opt/cross-pi-gcc ./cross-pi-gcc
tar -pczf raspi-toolchain.tar.gz ./cross-pi-gcc
