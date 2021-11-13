# Rasperry PI Toolchains

This was forked from <https://github.com/Pro/raspi-toolchain>. I use this to install the
toolchain in WSL2 for cross compiling and probably will work in other linux boxes.

Repository for Raspberry PI cross compiler using the new GCC8 and GCC9 for Raspbian Buster.
This supports all new Raspberry PIs (ARMv7), and the older ones, including Zero, A, B, B+ (ARMv6) with newer GCCs.

You can probably also use this repository for any other ARMv6 and ARMv7 devices. Check the original repo to get more details.

### Install toolchain
To cross-compile any executable you need the toolchain on your host and
you need to get current libraries and include files from raspberry o/s image.

Following steps will download the toolchain and raspbian buster o/s image and install toolchain and library in your linux. I tested them in my WSL2 ubuntu in a windows machine.

```bash
bash <(curl -s https://raw.githubusercontent.com/kkibria/raspi-toolchain/master/install.sh)
```

The install will create a `temp` directory. Once done, you can remove the ``temp`` directory.

### Test the setup
This repository contains a simple hello world example.
Make sure you have ``cmake`` installed. Following will build the executable.
```bash
bash temp/build_hello_world.sh
```
## Test the toolchain

To test the executable, copy it to your raspi.

```bash
# Use the correct IP address here
scp build/hello pi@192.168.1.PI:/home/pi/hello
ssh pi@192.168.1.PI
./hello
```

## How to know what is already installed in the root
this will tell us what is already installed in our wsl 
```
dpkg --root=/path/to/root/ --get-selections
```

## Use **libget** to get additional libraries from raspbian distro.
When you installed the toolchain in wsl2, it also installed ``libget``. 
This will install the libraries in ``~/rootfs`` from raspbian buster repo.
We can add the libraries to our root file system from ~/rootfs using `rsync`
```bash
pushd ~/rootfs
rsync -vR --progress -rl --delete-after --safe-links {etc,lib,sbin,usr,var} $HOME/rpi/rootfs
popd
```

## Use **liblink** to make links to library

When you installed the toolchain in wsl2, it also installed ``liblink``. Some link references
from other environments (such as `rustc`) don't have version numbers and
can give link error since the installed library we have
are all versioned. This command will create the links in ``~/liblink`` folder which
can be added to the library search path to help linking. 

As an example, following will create symlinks `libdbus-1.so`, `libgcrypt.so` `libgpg-error.so`
pointing to the latest versions found installed.

```bash
liblink dbus-1 gcrypt gpg-error
```
