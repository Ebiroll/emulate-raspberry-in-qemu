
# Running u-boot 

Here we log some useful u-boot commands 

```
U-Boot> version
U-Boot 2018.09-00427-g4024652143 (Jan 15 2024 - 18:52:56 +0100)

arm-none-eabi-gcc (15:10.3-2021.07-4) 10.3.1 20210621 (release)
GNU ld (2.38-3ubuntu1+15build1) 2.38

U-Boot> help
help
?       - alias for 'help'
base    - print or set address offset
bdinfo  - print Board Info structure
blkcache- block cache diagnostics and control
boot    - boot default, i.e., run 'bootcmd'
bootd   - boot default, i.e., run 'bootcmd'
bootefi - Boots an EFI payload from memory
bootelf - Boot from an ELF image in memory
bootm   - boot application image from memory
bootp   - boot image via network using BOOTP/TFTP protocol
bootvx  - Boot vxWorks from an ELF image
bootz   - boot Linux zImage image from memory
cmp     - memory compare
coninfo - print console devices and information
cp      - memory copy
crc32   - checksum calculation
dhcp    - boot image via network using DHCP/TFTP protocol
dm      - Driver model low level access
echo    - echo args to console
editenv - edit environment variable
env     - environment handling commands
exit    - exit script
ext2load- load binary file from a Ext2 filesystem
ext2ls  - list files in a directory (default /)
ext4load- load binary file from a Ext4 filesystem
ext4ls  - list files in a directory (default /)
ext4size- determine a file's size
false   - do nothing, unsuccessfully
fatinfo - print information about filesystem
fatload - load binary file from a dos filesystem
fatls   - list files in a directory (default /)
fatmkdir- create a directory
fatrm   - delete a file
fatsize - determine a file's size
fatwrite- write file into a dos filesystem
fdt     - flattened device tree utility commands
fstype  - Look up a filesystem type
go      - start application at address 'addr'
gpio    - query and control gpio pins
help    - print command description/usage
iminfo  - print header information for application image
imxtract- extract a part of a multi-image
itest   - return true/false on integer compare
lcdputs - print string on video framebuffer
load    - load binary file from a filesystem
loadb   - load binary file over serial line (kermit mode)
loads   - load S-Record file over serial line
loadx   - load binary file over serial line (xmodem mode)
loady   - load binary file over serial line (ymodem mode)
loop    - infinite loop on address range
ls      - list files in a directory (default /)
md      - memory display
mii     - MII utility commands
mm      - memory modify (auto-incrementing address)
mmc     - MMC sub system
mmcinfo - display MMC info
mw      - memory write (fill)
nfs     - boot image via network using NFS protocol
nm      - memory modify (constant address)
part    - disk partition related commands
ping    - send ICMP ECHO_REQUEST to network host
printenv- print environment variables
pxe     - commands to get and boot from pxe files
reset   - Perform RESET of the CPU
run     - run commands in an environment variable
save    - save file to a filesystem
saveenv - save environment variables to persistent storage
setcurs - set cursor position within screen
setenv  - set environment variables
setexpr - set environment variable as the result of eval expression
showvar - print local hushshell variables
size    - determine a file's size
sleep   - delay execution for some time
source  - run script from memory
sysboot - command to get and boot from syslinux files
test    - minimal test like /bin/sh
tftpboot- boot image via network using TFTP protocol
true    - do nothing, successfully
usb     - USB sub-system
usbboot - boot from USB device
version - print monitor, compiler and linker version
U-Boot> 
```

# mmc
The MMC (MultiMediaCard) subsystem is responsible for interfacing with and managing MMC-based storage devices. These devices include MMCs, SD (Secure Digital) cards, and eMMCs (embedded MMCs). 

```
nc 127.0.0.1 12344

U-Boot> mmc help
mmc help
mmc - MMC sub system

Usage:
mmc info - display info of the current MMC device
mmc read addr blk# cnt
mmc write addr blk# cnt
mmc erase blk# cnt
mmc rescan
mmc part - lists available partition on current mmc device
mmc dev [dev] [part] - show or set current mmc device [partition]
mmc list - lists available devices
mmc hwpartition [args...] - does hardware partitioning
  arguments (sizes in 512-byte blocks):
    [user [enh start cnt] [wrrel {on|off}]] - sets user data area attributes
    [gp1|gp2|gp3|gp4 cnt [enh] [wrrel {on|off}]] - general purpose partition
    [check|set|complete] - mode, complete set partitioning completed
  WARNING: Partitioning is a write-once setting once it is set to complete.
  Power cycling is required to initialize partitions after set to complete.
mmc setdsr <value> - set DSR register value

U-Boot> ls mmc 0:0

U-Boot> ls mmc 0:1
ls mmc 0:1
            overlays/
     4658   bcm2708-rpi-b-plus.dtb
    18693   COPYING.linux
     1447   LICENCE.broadcom
      137   issue.txt
  3495800   u-boot
    24678   bcm2708-rpi-b-rev1.dtb
     4379   bcm2708-rpi-b.dtb
    24800   bcm2708-rpi-cm.dtb
    25965   bcm2708-rpi-zero-w.dtb
    24772   bcm2708-rpi-zero.dtb
     5622   bcm2709-rpi-2-b.dtb
    26482   bcm2710-rpi-2-b.dtb
    28599   bcm2710-rpi-3-b-plus.dtb
    27980   bcm2710-rpi-3-b.dtb
    26289   bcm2710-rpi-cm3.dtb
    47471   bcm2711-rpi-4-b.dtb
    47576   bcm2711-rpi-cm4.dtb
    17856   bootcode.bin
      136   cmdline.txt
     1374   config.txt
    18974   LICENSE.oracle
     2313   bcm2835-rpi-b-plus.dts
      128   boot.scr

xx file(s), 1 dir(s)


```


# View content of boot.scr



```
U-Boot> fatload mmc 0:1 0x100000 boot.scr
fatload mmc 0:1 0x100000 boot.scr
128 bytes read in 45 ms (2 KiB/s)

U-Boot> md 0x100000
md 0x100000
00100000: 6f422d55 7320746f 70697263 00000074    U-Boot script...
00100040: 38000000 00000000 6c746166 2064616f    ...8....fatload 
00100050: 20636d6d 78302030 30323030 30303030    mmc 0 0x00200000
00100060: 73000000 00000000 00000000 6e69622e          kernel.bin
00100070: 6f670a3b 30783020 30303230 0a303030    ;.go 0x00200000.

```

We notice that u-boot loads kernel.bin at adress 0x00200000 and then starts app at 0x00200000.

To create a boot script
   mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "Boot Script" -d boot.cmd boot.scr

# Example boot script

```
# boot.cmd
echo "Select Kernel Version:"
echo "1. Kernel Version 1"
echo "2. Kernel Version 2"
echo "3. Kernel Version 3"
echo "Enter your choice (1-3): "
setenv choice
while test -z "$choice"
do
    read choice
done

if test "$choice" = "1"; then
    echo "Booting Kernel Version 1..."
    setenv bootargs 'set your bootargs here'
    fatload mmc 0:1 ${kernel_addr_r} /boot/kernel1.bin
    bootm ${kernel_addr_r}
elif test "$choice" = "2"; then
    echo "Booting Kernel Version 2..."
    setenv bootargs 'set your bootargs here'
    fatload mmc 0:1 ${kernel_addr_r} /boot/kernel2.bin
    bootm ${kernel_addr_r}
elif test "$choice" = "3"; then
    echo "Booting Kernel Version 3..."
    setenv bootargs 'set your bootargs here'
    fatload mmc 0:1 ${kernel_addr_r} /boot/kernel3.bin
    bootm ${kernel_addr_r}
else
    echo "Invalid choice, booting default kernel..."
    setenv bootargs 'set your default bootargs here'
    fatload mmc 0:1 ${kernel_addr_r} /boot/defaultkernel.bin
    bootm ${kernel_addr_r}
fi

```





