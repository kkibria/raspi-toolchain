#!/usr/bin/env bash

# install libget
mkdir -p $HOME/.local/{bin,share/libget}

INST="${HOME}/.local/share/libget"
ADDPATH="$HOME/.local/bin"
[[ ":$PATH:" != *":$ADDPATH:"* ]] && echo "export PATH=\$PATH:$ADDPATH" >> ~/.bashrc 

REPO="https://raw.githubusercontent.com/kkibria/raspi-toolchain/master"
curl -s "${REPO}/libget.py" --output ${INST}/libget.py

for BINNAME in "libget" "liblink"; do
    curl -s "${REPO}/${BINNAME}.sh" --output ${INST}/${BINNAME}.sh
    BIN="${ADDPATH}/${BINNAME}"

    cat <<EOF > "${BIN}"
#!/usr/bin/env bash
#
bash ${INST}/${BINNAME}.sh "\${@:1}"
EOF

    chmod ug+x "${BIN}"
done

exit 0
# work inside a temporary directory
mkdir temp-$$ && pushd temp-$$
wget https://github.com/kkibria/raspi-toolchain/releases/latest/download/raspi-toolchain-install.tar.gz
tar xfz raspi-toolchain-install.tar.gz

# This will ask for sudo permission as it starts running 
bash setup/install_cross.sh
popd
