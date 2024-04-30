# emulate-raspberry-in-qemu
Notes and scripts to start an emulated raspberry-pi in qemu

# Build qemu
Enable slirp for usermode

apt-get install libslirp-dev

../configure --disable-werror --enable-debug --enable-slirp 

Some info from here, https://www.marcusfolkesson.se/categories/qemu/

Board support

QEMU provides models of the following Raspberry Pi Boards:
| Machine      | Core          | Number of Cores | RAM     |
|--------------|---------------|-----------------|---------|
| raspi0       | ARM1176JZF-S  | 1               | 512 MiB |
| raspi1lap    | ARM1176JZF-S  | 1               | 512 MiB |
| raspi2b      | Cortex-A7     | 4               | 1 GB    |
| raspi3ap     | Cortex-A53    | 4               | 512 MiB |
| Raspi3b      | Cortex-A53    | 4               | 1 GB    |
   
Device support
QEMU provides support for the following devices:

- ARM1176JZF-S, Cortex-A7 or Cortex-A53 CPU

- Interrupt controller

- DMA controller

- Clock and reset controller (CPRMAN)

- System Timer

- GPIO controller

- Serial ports (BCM2835 AUX - 16550 based - and PL011)

- Random Number Generator (RNG)

- Frame Buffer

- USB host (USBH)

- GPIO controller

- SD/MMC host controller

- SoC thermal sensor

- USB2 host controller (DWC2 and MPHI)

- MailBox controller (MBOX)

- VideoCore firmware (property)

However, it still lacks support for these:

   Peripheral SPI controller (SPI)
   Analog to Digital Converter (ADC)
   Pulse Width Modulation (PWM)
## Set it up
Prerequisites
You will need to have qemu-system-aarch64, you could either build it from source [2] or let your Linux distribution install it for you.

If you are using Arch Linux, then you could use pacman

   sudo pacman -Sy qemu-system-aarch64
You will also need to do download and extract the Raspian image you want to use

   wget https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-09-26/2022-09-22-raspios-bullseye-arm64-lite.img.xz
   unxz 2022-09-22-raspios-bullseye-arm64-lite.img.xz
Loopback mount image
The image could be loopback mounted in order to extract the kernel and devicetree. First we need to figure out the first free loopback device



```
   sudo losetup -f
   /dev/loop0
```
Then we could use that device to mount:

```
   sudo losetup /dev/loop0  ./2022-09-22-raspios-bullseye-armh64-lite.img  -P
```
The -P option force the kernel to scan the partition table. As the sector size of the image is 512 bytes we could omit the --sector-size.

# Fresh disk for use in qemu

dd if=/dev/zero of=disk.img bs=1M count=1000

We make a boot only disk 

Other options

```
 sudo losetup --show -Pf ./disk.img
 /dev/loop1
 # if WSL does not report the parttions
 sudo fdisk /dev/loop1
 Then press p

# Graphical, allows right click on file
sudo apt-get update
sudo apt-get install gnome-disk-utility
```
# Boot example
In the directory boot-files are the Ubuntu server boot files.
The READNE explains what the files are.

To make a u-boot script
   apt install u-boot-tools
   mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "Boot Script" -d boot.cmd boot-files/boot.scr




# Mount the boot partition and root filesystem
```
   mkdir ./boot ./rootfs
   sudo mount /dev/loop0p1 ./boot/
   sudo mount /dev/loop0p2 ./rootfs/
```
   
Copy kernel and dtb

```
   cp boot/bcm2710-rpi-3-b.dtb .
   cp boot/kernel8.img .
   cp boot/kernel.img .
```

If you have any modification you want to do on the root filesystem, do it now before we unmount everything.

   sudo umount ./boot/
   sudo umount ./rootfs/

# Resize image
QEMU requires the image size to be a power of 2, so resize the image to 2GB

   qemu-img resize  ./2022-09-22-raspios-bullseye-arm64-lite.img 2G
Very note that this will lose data if you make the image smaller than it currently is

Wrap it up
Everything is now ready for start QEMU. The parameters are quite self-explained

```
   qemu-system-aarch64 \
       -M raspi3b \
       -append "rw earlyprintk loglevel=8 console=ttyAMA0,115200 root=/dev/mmcblk0p2 rootdelay=1" \
       -serial stdio \
       -dtb  bcm2710-rpi-3-b-plus.dtb \
       -sd ./2022-09-22-raspios-bullseye-arm64-lite.img \
       -kernel kernel8.img \
       -m 1G -smp 4
```
For network support
       -device usb-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5555-:22 \
	-nographic
    
# Here we go

   raspberrypi login: pi
   Password: raspberry

This might not work for newer versions. Default user is disabled.
Instead, 
```
Generate an encrypted password
$ echo 'password' | openssl passwd -6 -stdin
(The output of this command is an encrypted version of the password, necessary for the next step)

sudo nano boot/userconf.txt
Type your crendentials in it, following the format username:encrypted_password.
Press Ctrl+S to save and Ctrl+X to exit.

```

   
   Linux raspberrypi 5.10.103-v8+ #1529 SMP PREEMPT Tue Mar 8 12:26:46 GMT 2022 aarch64

   The programs included with the Debian GNU/Linux system are free software;
   the exact distribution terms for each program are described in the
   individual files in /usr/share/doc/*/copyright.

   Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
   permitted by applicable law.
   pi@raspberrypi:~$

# Once logged in

```

Start the cfdisk utility

$ sudo cfdisk /dev/mmcblk0
(/dev/mmcblk0 is the device file of the SD card on the Raspberry Pi 3. The cfdisk utility allows us to modify the partitions on the SD card)
In the utility, you can use the up and down arrow keys to navigate the partitions, and the side arrow keys to navigate the options.
Select the /dev/mmcblk0p2 partition and Resize it to fill the available space.
(The default given size should be just fine.)

If therer are filesystem errors online resize might not work and you can poweroof and do filesustem check.
e2fsck /dev/loop???

Save changes with Write, then Quit.

Resize the file system

$ sudo resize2fs /dev/mmcblk0p2
Shutdown and restart the VM

$ sudo shutdown now
```

To Update the VM's system

```
$ sudo apt update && sudo apt upgrade
(Note: The internet connection within the VM is very slow, and this will take a long time.)
```
## Use raspi-config to configure the system
```
$ sudo raspi-config
(This tool enables you to configure your locale, keyboard layout, hostname, password, as well as turn on SSH server, and more)
To access the VM from the host machine using SSH
Make sure that you have enabled the SSH server through the raspi-config utility.

$ ssh username@localhost -p 5555
(5555 being the forward port configured for the VM in the launch command.)
If you intend to change the VM's ssh server port, make sure to change the forwarded port (from 22) in the launch command as well.
```


# Raspberry pi 4 b

Not integrated into qemu yet, here is a version of qemu that supports that 
https://github.com/U007D/qemu 

We can try a newer kernel here,
   wget https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-12-11/2023-12-11-raspios-bookworm-arm64-lite.img.xz
But it turns out to be a bad idea, instead we reuse the 2022-09-22-raspios-bullseye-arm64-lite.img image
Make sure to extract 


https://github.com/raspberrypi/linux/issues/4900

qemu-system-aarch64  \
    -M raspi4b  \
    -cpu cortex-a72 \
    -kernel kernel8.img \
    -append "earlycon=pl011,mmio32,0xfe201000 console=ttyAMA0,115200 console=tty1  rootfstype=ext4 fsck.repair=yes rootwait quiet rootwait ip=192.168.10.2" \
    -d unimp,guest_errors  \
    -trace "bcm*" \
    -dtb bcm2711-rpi-4-b.dtb \
    -sd 2022-09-22-raspios-bullseye-arm64-lite.img \
    -m 2G -smp 4 \
    -serial tcp::12344,server,nowait -serial tcp::12345,server,nowait \
    -usb -device usb-mouse -device usb-kbd \
	 -device usb-net,netdev=net0 \
	 -netdev user,id=net0,hostfwd=tcp::5555-:22


/home/olas/work/qemu-stm32/rasp/qemu-system-aarch64  \
    -M raspi4b  \
    -cpu cortex-a72 \
    -kernel boot-files/framebuffer.elf \
    -append "earlycon=pl011,mmio32,0xfe201000 console=ttyAMA0,115200 console=tty1  rootfstype=ext4 fsck.repair=yes rootwait quiet rootwait ip=192.168.10.2" \
    -d unimp,guest_errors  \
    -trace "bcm*" \
    -dtb bcm2711-rpi-4-b.dtb \
    -sd 2022-09-22-raspios-bullseye-arm64-lite.img \
    -m 2G -smp 4 \
    -serial tcp::12344,server,nowait -serial tcp::12345,server,nowait \
    -usb -device usb-mouse -device usb-kbd \
	 -device usb-net,netdev=net0 \
	 -netdev user,id=net0,hostfwd=tcp::5555-:22


# Attach to uart,
nc 127.0.0.1 12344
nc 127.0.0.1 12345

Optionally use -serial stdio


  
Give it some time... With trace it starts even more slowly.
Also file system check might take a very long time.


# Kernel panic
We could get kernelpanic when mounting the resized image, root=/dev/mmcblk1p2
Kernel panic - not syncing VFS Unable to mount root fs on unknown-block(179,2)
   [    6.350264] of_cfs_init: OK
   [    6.383446] mmc1: host does not support reading read-only switch, assuming write-enable
   [    6.392895] mmc1: new high speed SDHC card at address 4567
   [    6.418818] mmcblk1: mmc1:4567 QEMU! 4.00 GiB
   [    6.487458] mmcblk1: mmc1:4567 QEMU! 4.00 GiB


```
2023-12-11-raspios-bookworm-arm64-lite.img

[  126.580914] Warning: unable to open an initial console.
[  126.615750] /dev/root: Can't open blockdev
[  126.618640] VFS: Cannot open root device "mmcblk1p2" or unknown-block(179,2): error -6
[  126.622386] Please append a correct "root=" boot option; here are the available partitions:
[  126.626772] 0100            4096 ram0
[  126.627328]  (driver?)
[  126.636391] 0101            4096 ram1
[  126.636642]  (driver?)
[  126.636943] 0102            4096 ram2
[  126.637141]  (driver?)
[  126.637286] 0103            4096 ram3
[  126.637400]  (driver?)
[  126.637524] 0104            4096 ram4
[  126.637634]  (driver?)
[  126.655402] 0105            4096 ram5
[  126.655554]  (driver?)
[  126.660600] 0106            4096 ram6
[  126.660732]  (driver?)
[  126.663148] 0107            4096 ram7
[  126.663282]  (driver?)
[  126.667267] 0108            4096 ram8
[  126.667403]  (driver?)
[  126.670132] 0109            4096 ram9
[  126.670408]  (driver?)
[  126.673442] 010a            4096 ram10
[  126.673575]  (driver?)
[  126.675608] 010b            4096 ram11
[  126.676526]  (driver?)
[  126.679183] 010c            4096 ram12
[  126.679388]  (driver?)
[  126.684054] 010d            4096 ram13
[  126.684194]  (driver?)
[  126.688778] 010e            4096 ram14
[  126.688937]  (driver?)
[  126.691296] 010f            4096 ram15
[  126.691448]  (driver?)
[  126.694245] b300         4194304 mmcblk1
[  126.694502]  driver: mmcblk
[  126.697987] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(179,2)
[  126.702327] CPU: 3 PID: 1 Comm: swapper/0 Not tainted 6.1.0-rpi7-rpi-v8 #1  Debian 1:6.1.63-1+rpt1
[  126.707621] Hardware name: Raspberry Pi 4 Model B (DT)
[  126.710857] Call trace:
[  126.712641]  dump_backtrace.part.0+0xec/0x100
[  126.714594]  show_stack+0x20/0x30
[  126.716409]  dump_stack_lvl+0x88/0xb4
[  126.718293]  dump_stack+0x18/0x34
[  126.719731]  panic+0x1a0/0x370
[  126.721242]  mount_block_root+0x194/0x240
[  126.722158]  mount_root+0x210/0x24c
[  126.722993]  prepare_namespace+0x138/0x178
[  126.724814]  kernel_init_freeable+0x29c/0x2c8
[  126.726976]  kernel_init+0x2c/0x140
[  126.728394]  ret_from_fork+0x10/0x20
[  126.730900] SMP: stopping secondary CPUs
[  126.733465] Kernel Offset: disabled
[  126.733956] CPU features: 0x80000,2003c080,0000421b
[  126.735082] Memory Limit: none
[  126.736666] ---[ end Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(179,2) ]---

When trying an older kernel and removing  init=/usr/lib/raspberrypi-sys-mods/firstboot 
 and changing in append to root=/dev/mmcblk0p2

[    0.000000] Booting Linux on physical CPU 0x0000000000 [0x410fd083]
[    0.000000] Linux version 5.15.61-v8+ (dom@buildbot) (aarch64-linux-gnu-gcc-8 (Ubuntu/Linaro 8.4.0-3ubuntu1) 8.4.0, GNU ld (GNU Binutils for Ubuntu) 2.34) #1579 SMP PREEMPT Fri Aug 26 11:16:44 BST 2022
[    0.000000] Machine model: Raspberry Pi 4 Model B
[    0.000000] earlycon: pl11 at MMIO32 0x00000000fe201000 (options '')
[    0.000000] printk: bootconsole [pl11] enabled


[    7.183858] of_cfs_init: OK
[    7.216110] mmc1: host does not support reading read-only switch, assuming write-enable
[    7.221825] mmc1: new high speed SDHC card at address 4567
[    7.239435] mmcblk1: mmc1:4567 QEMU! 4.00 GiB
[    7.298046]  mmcblk1: p1 p2

olas@raspberrypi:~$ cat /proc/cpuinfo
processor       : 0
BogoMIPS        : 125.00
Features        : fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid
CPU implementer : 0x41
CPU architecture: 8
CPU variant     : 0x0
CPU part        : 0xd08
CPU revision    : 3

processor       : 1
BogoMIPS        : 125.00
Features        : fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid
CPU implementer : 0x41
CPU architecture: 8
CPU variant     : 0x0
CPU part        : 0xd08
CPU revision    : 3

processor       : 2
BogoMIPS        : 125.00
Features        : fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid
CPU implementer : 0x41
CPU architecture: 8
CPU variant     : 0x0
CPU part        : 0xd08
CPU revision    : 3

processor       : 3
BogoMIPS        : 125.00
Features        : fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid
CPU implementer : 0x41
CPU architecture: 8
CPU variant     : 0x0
CPU part        : 0xd08
CPU revision    : 3

Hardware        : BCM2835
Model           : Raspberry Pi 4 Model B
```

# root=PARTUUID=4e639091-02
   
Make sure to check boot/cmdline.txt to match -append arguments

Double check the UUID

   od -A n -X -j 440 -N 4 2023-12-11-raspios-bookworm-arm64-lite.img

But fdisk does a better job Disk identifie

   Welcome to fdisk (util-linux 2.37.2).
   Changes will remain in memory only, until you decide to write them.
   Be careful before using the write command.


   Command (m for help): p
   Disk 2023-12-11-raspios-bookworm-arm64-lite.img: 4 GiB, 4294967296 bytes, 8388608 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: dos
   Disk identifier: 0x4e639091

  Device                                      Boot   Start     End Sectors  Size Id Type
  2023-12-11-raspios-bookworm-arm64-lite.img1         8192 1056767 1048576  512M  c W95 FAT32 (LBA)
  2023-12-11-raspios-bookworm-arm64-lite.img2      1056768 5349375 4292608    2G 83 Linux

  Command (m for help): q


# U-boot

Nice way to get to know more about u-boot

https://elinux.org/RPi_U-Boot

make rpi_3_defconfig

make

If you get compile error, duplicate symbol yll....

grep YYLTYPE  *

    add extern YLLTYPE yll....

 
# Advanced configuration,

   make CROSS_COMPILE=arm-none-eabi- ARCH=arm menuconfig
 

   cp u-boot /home/olas/emulate-raspberry-in-qemu/u-boot.elf

   gdb-multiarch u-boot -ex'target extended-remote:1234'

Make sure you add -S -s when staring up qemu
and change  -kernel to u-boot.elf



# Bare metal raspi

https://www.rpi4os.com/

The example 
boot-files/framebuffer.elf
boot-files/miniuart.elf

Are build from this repo

# Toolchain 
cd download


https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads

tar xvf  /mnt/c/Users/XXX/Downloads/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-elf.tar.xz

https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain

/mnt/c/Users/olof.astrand/work/emulate-raspberry-in-qemu/rpi4-osdev/download/arm-gnu-toolchain-13.2.R
el1-x86_64-aarch64-none-elf/bin/aarch64-none-elf-c++

# QNX
Regarding serial

https://forums.openqnx.com/t/topic/47479/3






  
