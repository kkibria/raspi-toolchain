#!/usr/bin/env bash

# work inside a temporary directory
mkdir temp-$$ && pushd temp-$$
wget https://github.com/kkibria/raspi-toolchain/releases/latest/download/raspi-toolchain-install.tar.gz
tar xfz raspi-toolchain-install.tar.gz

# This will ask for sudo permission as it starts running 
bash setup/install_cross.sh
popd
