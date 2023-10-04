

## Building Ultra96v2 Petalinux artefacts for use with libvmm


The project provides patches to configure Anvet build scripts
so they produce proper artefacts to be used in <i>libvmm</i> - 
Virtual Machine Monitor (VMM) built on the seL4 Microkit. 


Script <i>Setup-petalinux-ultra96v2-libvmm.sh</i> downloads Avnet repositories
and applies a patch to modify <i>petalinux/scripts</i> directory.


Current version of the script uses Xilinx tools of version 2020.1,
please change it to the required one.

</br>

### Steps

</br>

1. Make sure Vivado, Vitis and petalinux packages are installed, then
run the following commands to get and patch the Avnet build scripts:


```
mkdir petalinux-ultra96v2; cd petalinux-ultra96v2
git clone git@github.com:malus-brandywine/petalinux-ultra96v2-libvmm.git
cd petalinux-ultra96v2-libvmm
./Setup-petalinux-ultra96v2-libvmm.sh
```

After the repositories has been set up you will find 3 new directories
in <i>petalinux-ultra96v2</i>:


```
bdf
hdl
petalinux
```

2. Open shell which you are going to build the BSP in and run Xilinx
scripts to setup the building environment:


```
. [path_to_petalinux]/petalinux-v2020.1/settings.sh
. [path_to_vivado]/Vivado/2020.1/settings64.sh
. [path_to_vitis]/Vitis/2020.1/settings64.sh
```

3. In the shell, change directory to <i>petalinux/scripts</i> and run the script
to build BSP:


```
cd petalinux/scripts
./make_ultra96v2.vmm.sh
```

The final lines of the log should be:



>INFO: Creating BSP</br>
INFO: Generating package ultra96v2_oob_2020_1.bsp...</br>
INFO: BSP is ready</br>


</br>

4. If the build was successful, you will find the artefacts intended for
<i>libvmm</i> --- <i>image</i> and <i>rootfs.cpio.gz</i> --- in directory
<i>petalinux/projects/ultra96v2_oob_2020_1/images/linux</i>

</br>

</br>


### Boot scenario and modifications done

</br>

The project uses the common <i>zynqmp</i> boot scenario: firmware loads
ATF and U-Boot, U-Boot loads a custom application image.

The setting is beneficial for development stage since U-Boot enables loading
a custom image over Ethernet. I used an USB-to-Ethernet adapter tp-link UE300,
so this one was added to the U-Boot configuration.

</br>

Next, <i>Microkit</i>-based system image is loaded by U-Boot with command "go". Xilinx
implemented its own version of the command which sets a PE to exception level EL1.

When running an image of <i>Microkit</i>-based system with <i>libvmm</i> component,
U-Boot has to set a PE to EL2 before passing the execution flow to the image.
To solve it, I added the second parameter to the command - string "debug":</br>

$ go <i>addr</i> <i>[debug]</i>

</br>

If "debug" is present, then U-Boot sets EL2, otherwise it sets EL1.

</br>


Example of U-Boot command sequence:

```
setenv ipaddr 192.168.9.25
setenv serverip 192.168.9.1
setenv netmask 255.255.255.0
setenv primeth usb_ether
setenv acteth usb_ether
setenv usbnet_devaddr ca:fe:ca:fe:00:01
setenv usbnet_hostaddr 80:e8:2c:e7:3a:21

usb start

tftpboot 0x40000000 loader.img

go 0x40000000 debug
```

To use modified U-Boot, update file BOOT.BIN on the boot SD card.

</br>


The third, a rootfs image built with original recipe <i>avnet-minimal-image</i>
is pretty large (rootf.cpio: ~250M).</br>
I patched <i>avnet-image-minimal.inc</i> so it inherits directly <i>core-image</i>
instead of inheriting the same recipe
throught <i>petalinux-image-common.inc</i>.</br>
Be adviced: this is considerably reduced rootfs image with many packages dropped.

</br>


### Links

</br>

Useful howto articles at Ultra96v2 support community:


   - [Avnet HDL git HOWTO (Dec 2019)](https://community.element14.com/technologies/fpga-group/b/blog/posts/avnet-hdl-git-howto-vivado-2020-1-and-earlier)</br>
   - [Using Avnet Build Scripts to Build a PetaLinux BSP (May 2020)](https://community.element14.com/technologies/fpga-group/b/blog/posts/using-avnet-build-scripts-to-build-a-petalinux-bsp-2019-2-and-earlier)

</br>

~
