

## Building Ultra96v2 Petalinux artefacts for use with sel4cp_VMM


The project offers patches to configure scripts provided by Avnet
the way the built artefacts can be used by `sel4cp_VMM` - 
Virtual Machine Monitor (VMM) built on the seL4 Core Platform (seL4CP). 


Script `Setup-petalinux-ultra96v2-sel4cpvmm.sh` downloads Avnet repositories
and applies the patch to modify `petalinux/scripts` directory.


Current version of the script uses Xilinx tools of version 2020.1,
please change it to the required one.

</br>

### Steps

</br>

1. Make sure Vivado, Vitis and petalinux packages are installed, then
run the following commands to get and patch the Avnet build scripts:


```
mkdir petalinux-ultra96v2; cd petalinux-ultra96v2
git clone git@github.com:malus-brandywine/petalinux-ultra96v2-sel4cpvmm.git
cd petalinux-ultra96v2-sel4cpvmm
./Setup-petalinux-ultra96v2-sel4cpvmm.sh
```

After the repositories has been set up you will find 3 new directories
in petalinux-ultra96v2:


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

3. In the shell, change directory to petalinux/scripts and run the script
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
<i>sel4cp_vmm</i> - `image` and `rootfs.cpio.gz` - in directory
`petalinux/projects/ultra96v2_oob_2020_1/images/linux`

</br>

</br>


### Boot scenario and modifications done

</br>

The project uses the common <i>zynqmp</i> boot scenario: firmware loads
ATF and U-Boot, U-Boot loads a custom application image.

The setting is beneficial for development stage since U-Boot offers loading
a custom image over Ethernet. I used an USB-to-Ethernet adapter tp-link UE300,
so this one was added to the U-Boot configuration.

</br>

Next, <i>sel4cp</i>-based system image is loaded by U-Boot with command "go". Xilinx
implemented its own version of the command which sets a PE to exception level EL1.

When running an image of <i>sel4cp</i>-based system with <i>sel4cp_vmm</i> component,
U-Boot has to set a PE to EL2 before passing the execution flow to the image.
To solve it, I added the second parameter to the command - string "debug":</br>

$ go addr [debug]

</br>

If "debug" is present, then U-Boot sets EL2, otherwise it sets EL1.

</br>


Example of U-Boot script:

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

</br>


The third, a rootfs image built with original recipe `avnet-minimal-image`
is pretty large (rootf.cpio: ~250M). I patched `avnet-image-minimal.inc`
so it inherits directly `core-image` instead of inheriting the same recipe
throught `petalinux-image-common.inc`.</br>
Be adviced: this is considerably reduced rootfs image with many packages dropped.

</br>


### Links

</br>

Useful howto articles at Ultra96v2 support community:


   - [Avnet HDL git HOWTO (Dec 2019)](https://community.element14.com/technologies/fpga-group/b/blog/posts/avnet-hdl-git-howto-vivado-2020-1-and-earlier)</br>
   - [Using Avnet Build Scripts to Build a PetaLinux BSP (May 2020)](https://community.element14.com/technologies/fpga-group/b/blog/posts/using-avnet-build-scripts-to-build-a-petalinux-bsp-2019-2-and-earlier)

</br>

~
