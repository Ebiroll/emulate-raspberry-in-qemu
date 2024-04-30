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

qemu 9.0.0 Now has support
https://github.com/U007D/qemu 

We can try a newer kernel here,
   wget https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-12-11/2023-12-11-raspios-bookworm-arm64-lite.img.xz
But it turns out to be a bad idea, instead we reuse the 2022-09-22-raspios-bullseye-arm64-lite.img image
Make sure to extract as described earlier
```
 sudo losetup /dev/loop0  ./2023-12-11-raspios-bookworm-arm64-lite.img  -P
 sudo mount /dev/loop0p1 boot
cat boot/cmdline.txt
console=serial0,115200 console=tty1 root=PARTUUID=4e639091-02 rootfstype=ext4 fsck.repair=yes rootwait quiet init=/usr/lib/raspberrypi-sys-mods/firstboot

cp boot/bcm2711-rpi-* .
cp boot/initramfs8 .
cp boot/kernel8.img .
sudo umount boot
```



https://github.com/raspberrypi/linux/issues/4900

Firstboot
This generates ssh keys and then reboots
```
 ./qemu-system-aarch64 -M raspi4b  -kernel kernel8.img -append "console=serial0,115200 console=tty1 root=PARTUUID=4e639091-02 rootfstype=ext4 fsck.repair=yes rootwait quiet init=/usr/lib/raspberrypi-sys-mods/firstboot" -initrd initramfs8 -d unimp,guest_errors -trace "bcm*" -dtb bcm2711-rpi-cm4.dtb -sd 2023-12-11-raspios-bookworm-arm64-lite.img  -serial tcp::12344,server,nowait -serial tcp::12345,server,nowait
```

Now it should be setup to go.


```
./qemu-system-aarch64 -M raspi4b  -kernel kernel8.img -append "console=serial0,115200 console=tty1 root=PARTUUID=4e639091-02 rootfstype=ext4 fsck.repair=yes rootwait quiet" \
  -initrd initramfs8 -d unimp,guest_errors -trace "bcm*" -dtb bcm2711-rpi-cm4.dtb \
  -sd 2023-12-11-raspios-bookworm-arm64-lite.img  -serial stdio

```
You can experiment alittle here,
And also repair disk
sudo e2fsck /dev/loop0p2

![image](https://github.com/Ebiroll/emulate-raspberry-in-qemu/assets/8543484/0bd8cda2-c119-42b5-a314-d6216acfba47)



You can also try the framebuffer example 
qemu-system-aarch64 -kernel boot-files/framebuffer.elf  -M raspi4b  -d unimp,guest_errors      -trace "bcm*"

And miniuart
```
/qemu-system-aarch64 -kernel boot-files/miniuart.elf  -M raspi4b  -d unimp,guest_errors      -trace "bcm*"  -serial tcp::12344,server,nowait -serial tcp::12345,server -serial stdio

nc 127.0.0.1 12345
Hello world!
apa
apa
```

Old try with other version

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
See earlier example of how to invoke.

https://www.rpi4os.com/

The example 
boot-files/framebuffer.elf
boot-files/miniuart.elf

Are build from this repo

# Toolchain 
```
cd download

https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads

tar xvf  /mnt/c/Users/XXX/Downloads/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-elf.tar.xz

https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain
../download/arm-gnu-toolchain-13.2.R
el1-x86_64-aarch64-none-elf/bin/aarch64-none-elf-c++
```

# QNX
Regarding serial

https://forums.openqnx.com/t/topic/47479/3






  
