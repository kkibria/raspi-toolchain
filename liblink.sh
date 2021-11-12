#!/usr/bin/env bash

if [ -z "${1}" ]; then
1>&2 cat <<-"EOF"
'liblink' creates absolute soft link of the specified library in liblink folder at your home directory.
usage: liblink <package_name>

liblink will prefix the package name with "lib"
EOF
exit 1
fi

libname=lib${1}.so
libpaths=()
srchpaths="$HOME/rootfs $HOME/rpi/rootfs"
for srchpath in $srchpaths; do
    # srchpath="$( cd -- $srchpath" &> /dev/null && pwd )"
    pushd $srchpath &> /dev/null
    srchpath=$(pwd)
    popd &> /dev/null
    libpaths+=( $(find -L $srchpath | grep -e ${libname}) )
done

# find the latest version
sellib=
selpath=
for libpath in ${libpaths[@]}; do
    if [[ ! -L "$libpath" ]]; then
        bn="${libpath##*/}"
        if [[ $bn > $sellib ]]; then
            sellib=$bn
            selpath=$libpath
        fi
    fi
done

if [ -z "${selpath}" ]; then
    1>&2 echo "Can't find ${1}"
    exit 1
fi

linkfolder=${HOME}/liblink
mkdir -p ${linkfolder}
echo "Creating link to ${selpath}"
ln -s ${selpath} ${linkfolder}/${libname}