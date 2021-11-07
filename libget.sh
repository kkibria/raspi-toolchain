#!/usr/bin/env bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

PKGS=()
markopt='-m'

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -d|--dry-run)
      markopt=""
      shift # past argument
      ;;

    -i|--image)
      IMG=$(realpath "$2")
      shift # past argument
      shift # past value
      ;;
    -p|--package)
      PKGS+=("$2")
      shift # past argument
      shift # past value
      ;;
    *)    # unknown option
      shift # past argument
      ;;
  esac
done

PKGS=${PKGS[@]}

if [ -z "${PKGS}" ]; then
cat <<-"EOF"
'libget' installs packages from pi repository into rootfs at your home directory.

usage: libget [-d|--dry-run] [-i|--image] <image_file> ([-p|--package] <package_name>)+
it keeps its states in .local/libget in your home directory.
EOF
exit 1
fi

rootfs="${HOME}/rootfs"
rootfs=$(realpath $rootfs)

#
tempdir=".temp.libget.$$"
echo "temporary build area: $tempdir"
mkdir -p $tempdir 
pushd $tempdir

#
mkdir -p $rootfs

if [ -z "${IMG}" ]; then
    echo "no image to be mounted"
    selopt=""
else 
    echo "image $IMG to be mounted"
    selopt="-s sel"
    MNT=m
    fdisk -lu $IMG
    # Disk 2021-05-07-raspios-buster-armhf-lite.img: 1.76 GiB, 1874853888 bytes, 3661824 sectors
    # Units: sectors of 1 * 512 = 512 bytes
    # Sector size (logical/physical): 512 bytes / 512 bytes
    # I/O size (minimum/optimal): 512 bytes / 512 bytes
    # Disklabel type: dos
    # Disk identifier: 0x9730496b

    # Device                                    Boot  Start     End Sectors  Size Id Type
    # 2021-05-07-raspios-buster-armhf-lite.img1        8192  532479  524288  256M  c W95 FAT32 (LBA)
    # 2021-05-07-raspios-buster-armhf-lite.img2      532480 3661823 3129344  1.5G 83 Linux
    mkdir -p $MNT/{p1,p2}
    sudo mount -o loop,offset=4194304,sizelimit=268435456 $IMG $MNT/p1
    sudo mount -o loop,offset=272629760 $IMG $MNT/p2
    #
    dpkg --root=$MNT/p2 --get-selections > sel
    #
    sudo umount $MNT/{p1,p2}
fi

python3 $SCRIPT_DIR/libget.py $markopt $selopt -p $PKGS > deblist
while read -r deburl; do
    if [ -z "${markopt}" ]; then
        echo "---dry-run $deburl"
    else
        echo "##"
        wget -nv $deburl
        dpkg-deb -x ${deburl##*/} $rootfs
    fi
done < deblist
echo "leaving $tempdir"
popd