

## Building Petalinux for sel4cp_vmm


The project offers patches to configure and run scripts provided by Avnet
to build Ultra96v2 BSP.



Script Setup-petalinux-ultra96v2-sel4cpvmm.sh downloads Avnet repositories
and applies the patch to modify petalinux/scripts directory.


Current version of the script uses Xilinx tools of version 2020.1,
please change it to the required one.

</br>

### Instuction


1. Make sure Vivado, Vitis and petalinux packages are installed, then
run the following commands to get Avnet build scripts:

'''
mkdir petalinux-ultra96v2; cd petalinux-ultra96v2
git clone git@github.com:malus-brandywine/petalinux-ultra96v2-sel4cpvmm.git
cd petalinux-ultra96v2-sel4cpvmm
./Setup-petalinux-ultra96v2-sel4cpvmm.sh
'''

After the repositories has been set up you will find 3 new directories
in petalinux-ultra96v2:


>bdf
hdl
petalinux


2. Open shell which you are going to build the BSP in and run Xilinx
scripts to setup the building environment:

'''
. [path_to_petalinux]/petalinux-v2020.1/settings.sh
. [path_to_vivado]/Vivado/2020.1/settings64.sh
. [path_to_vitis]/Vitis/2020.1/settings64.sh
'''

3. In the shell, change directory to petalinux/scripts and run the script
to build BSP:

'''
cd petalinux/scripts
./make_ultra96v2.vmm.sh
'''

Final lines of the log should be:


> INFO: Creating BSP
INFO: Generating package ultra96v2_oob_2020_1.bsp...
INFO: BSP is ready

4. If the build was successful, you will find the artefacts intended for
sel4cp_vmm - image and rootfs.cpio.gz - in directory
'petalinux/projects/ultra96v2_oob_2020_1/images/linux'

</br>

### Boot scenario and modifications to build scripts


The project uses the "default" zynqmp boot scenario: firmware loads
ATF and U-Boot, U-Boot loads a custom application image.

The setting is beneficial for a development stage since U-Boot offers loading
a custom image over Ethernet. I used USB-to-Ethernet adapter tp-link UE300,
so this one was added to U-Boot configuration.


Next, an application image is loaded by U-Boot with command "go". Xilinx
implemented own version of the command to set a PE to exception level EL1.

To run an image of sel4cp system with sel4cp_vmm component, U-Boot has to set
EL2 before passing the execution flow to the image. To solve it, I added
the second parameter to the command - string "debug".
If "debug" is present, then U-Boot sets EL2, otherwise it sets EL1.

</br>


> Example of U-Boot script:</br>
</br>
> setenv ipaddr 192.168.9.25</br>
setenv serverip 192.168.9.1</br>
setenv netmask 255.255.255.0</br>
setenv primeth usb_ether</br>
setenv acteth usb_ether</br>
setenv usbnet_devaddr ca:fe:ca:fe:00:01</br>
setenv usbnet_hostaddr 80:e8:2c:e7:3a:21</br>
</br>
usb start</br>
</br>
tftpboot 0x40000000 loader.img
</br>
go 0x40000000 debug


</br>


The third, a rootfs image built with original recipe "avnet-minimal-image"
is pretty large (rootf.cpio: ~250M). I patched avnet-image-minimal.inc
so it inherits directly "core-image" instead of inheriting the same recipe
throught "petalinux-image-common.inc".
Be adviced: this is considerably reduced rootfs image with many packaged dropped.

</br>


### Links

</br>

Useful howto links from Ultra96v2 support community:
[Avnet HDL git HOWTO (Dec 2019)](https://community.element14.com/technologies/fpga-group/b/blog/posts/avnet-hdl-git-howto-vivado-2020-1-and-earlier)
[Using Avnet Build Scripts to Build a PetaLinux BSP (May 2020)](https://community.element14.com/technologies/fpga-group/b/blog/posts/using-avnet-build-scripts-to-build-a-petalinux-bsp-2019-2-and-earlier)


~
