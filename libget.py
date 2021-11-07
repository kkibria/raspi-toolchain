import argparse
import requests
import gzip
import os
import sys
from pathlib import Path

chtick = 10000

def save_content(url, filename):
    print('saving to {}'.format(filename), file=sys.stderr)
    cnt = 0
    f = open(filename, 'wb')
    resp = requests.get(url, stream=True)
    if resp.status_code != 200:
        print('not 200!')
        print(resp)
        print(url)
        return
    for chunk in resp:
        f.write(chunk)
        cnt = cnt+1
        if (cnt%chtick) == (chtick-1):
            print('.', end='', file=sys.stderr, flush=True)

    f.flush()
    f.close()
    print('.', file=sys.stderr)

class LibGet:
    def __init__(self, repo, release):
        # _raspbianUrl = 'http://raspbian.raspberrypi.org/raspbian'
        self.repo = repo
        self.pkgs = None
        self.names = set()
        self.release = release

    def get_db(self):
        # _raspbianRelease = 'buster'
        _raspbianRelease = self.release
        _raspbianUrl = self.repo
        # _raspbianUrl = 'http://archive.raspbian.org/raspbian'
        packagesUrl = "{}/dists/{}/main/binary-armhf/Packages.gz".format(_raspbianUrl, _raspbianRelease)
        fn = os.path.join(os.path.expanduser('~'), ".local/libget", os.path.basename(packagesUrl))
        os.makedirs(os.path.dirname(os.path.realpath(fn)), exist_ok=True)
        if not os.path.exists(fn):
            save_content(packagesUrl, fn)
        self.bld_db(fn)

    def bld_db(self, fn):
        with gzip.open(fn, 'rb') as f:
            file_content = f.read()

        l = file_content.split(b'\n\n')
        self.pkgs = {}
        for i in l:
            lines = i.split(b'\n')
            idict = {}
            lastidx = None
            for line in lines:
                if len(line) == 0:
                    continue
                if line[0] == 32:
                    idict[lastidx] += b'\n' + line
                else:
                    n = line.split(b': ')
                    lastidx = n[0]
                    if len(n) < 2:
                        idict[lastidx] = b''
                    else:
                        idict[lastidx] = n[1]

            if not lastidx is None:
                if idict[b'Package'] in self.pkgs:
                    print("Error: duplicate pkg {}, ignored!".format(idict[b'Package'].decode('utf-8')))
                else:
                    self.pkgs[idict[b'Package']] = idict

    def get_pkg(self, pkgnames):
        for pkgname in pkgnames:
            idx = pkgname.encode('utf_8')
            self.savename(idx)


    def savename(self, idx):
        self.names.add(idx)
        pkg = self.pkgs[idx]
        if b'Depends' in pkg:
            for dep in pkg[b'Depends'].split(b', '):
                depidx = dep.split(None, 1)[0]
                if depidx not in self.names:
                    self.savename(depidx)

class GetSel:
    def __init__(self, fn, mark):
        self.fn = fn
        self.installed = []
        self.instfn = os.path.join(os.path.expanduser('~'), ".local/libget/installed")
        self.mark = mark

    def parse(self):
        if not self.fn is None:
            with open(self.fn, "r") as f:
                lines = f.readlines()
            for line in lines:
                tokens = line.split()
                if tokens[1] == 'install':
                    lib = tokens[0].split()
                    self.installed.append(lib[0])

        if os.path.exists(self.instfn):
            with open(self.instfn, "r") as f:
                lines = f.readlines()
            for line in lines:
                tokens = line.split()
                # print("was installed {}", tokens[0], file=sys.stderr)
                self.installed.append(tokens[0])
        else:
            os.makedirs(os.path.dirname(os.path.realpath(self.instfn)), exist_ok=True)
            Path(self.instfn).touch()

    def isInstalled(self, pkgname):
        if pkgname in self.installed:
            return True
        else:
            if self.mark:
                with open(self.instfn, "a") as f:
                    print(pkgname, file=f)
            # print("gotten installed {}", pkgname, file=sys.stderr)
            self.installed.append(pkgname)
            return False


class InstallLib:
    def __init__(self, pkgname, selfn, mark):
        self.p = pkgname
        self.l = LibGet('http://raspbian.raspberrypi.org/raspbian', 'buster')
        self.s = GetSel(selfn, mark)

    def deblist(self):
        self.s.parse()
        
        self.l.get_db()
        self.l.get_pkg(self.p)

        for idx in self.l.names:
            pkg = self.l.pkgs[idx]
            # print(pkg.keys())
            if not self.s.isInstalled(idx.decode("utf-8")):
                # print(idx.decode("utf-8"), 
                #  pkg[b'Filename'].decode("utf-8"), 
                #  pkg[b'Version'].decode("utf-8"))
                print("{}/{}".format(self.l.repo, pkg[b'Filename'].decode("utf-8")))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='LIBGET')
    parser.add_argument("-s", "--selection", action="store",
                           help="file containing 'dpkg --get-selections' produced output from an image",
                           default=None)
    parser.add_argument("-p", "--package", action="append",
                           help="package, multiple packages allowed",
                           required=True)
    parser.add_argument("-m", "--mark", action="store_true",
                           help="mark cache so that we don't not reinstall in future")
    args = parser.parse_args()
    x = vars(args)
    il = InstallLib(x['package'], x['selection'], x['mark'])
    il.deblist()

# python3 libget.py dbus gs.txt
# print(pkgs[b'dbus'])
# packagesUrl = "{}/dists/{}/main/binary-armhf/Packages.gz".format(_raspbianUrl, _raspbianRelease)
