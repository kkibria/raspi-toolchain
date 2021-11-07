#!/usr/bin/env bash

# install libget
mkdir -p $HOME/.local/{bin,share/libget}

INST="${HOME}/.local/share/libget"
ADDPATH="$HOME/.local/bin"
BIN="${ADDPATH}/libget"
[[ ":$PATH:" != *":$ADDPATH:"* ]] && echo "export PATH=\$PATH:$ADDPATH" >> ~/.bashrc 

REPO="https://raw.githubusercontent.com/kkibria/raspi-toolchain/master"
curl -s "${REPO}/libget.sh" --output ${INST}/libget.sh
curl -s "${REPO}/libget.py" --output ${INST}/libget.py

cat <<EOF > "${BIN}"
#!/usr/bin/env bash
#
bash ${INST}/libget.sh "\${@:1}"
EOF
chmod ug+x "${BIN}"

# work inside a temporary directory
mkdir temp-$$ && pushd temp-$$
wget https://github.com/kkibria/raspi-toolchain/releases/latest/download/raspi-toolchain-install.tar.gz
tar xfz raspi-toolchain-install.tar.gz

# This will ask for sudo permission as it starts running 
bash setup/install_cross.sh
popd
