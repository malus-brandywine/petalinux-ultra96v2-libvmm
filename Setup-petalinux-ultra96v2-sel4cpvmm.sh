#!/bin/sh


git clone https://github.com/avnet/bdf.git
git clone https://github.com/avnet/hdl.git
git clone https://github.com/avnet/petalinux.git

cd bdf
git checkout master

cd ../hdl
git checkout 2020.1

cd ../petalinux
git checkout 2020.1

cd ..
patch -d petalinux/scripts/ < Configure-Petalinux-BSP-For-Sel4cpvmm-System.patch

chmod ug+x petalinux/scripts/make_ultra96v2.vmm.sh



