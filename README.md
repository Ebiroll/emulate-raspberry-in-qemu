# emulate-raspberry-in-qemu
Notes and scripts to start an emulated raspberry-pi in qemu

Some info from here, https://www.marcusfolkesson.se/categories/qemu/

Board support
QEMU provides models of the following Raspberry Pi Boards:

Machine	Core	Number of cores	RAM
   raspi0	ARM1176JZF-S  	1	512 MiB
   raspi1lap	ARM1176JZF-S	1	512 MiB
   raspi2b	Coretx-A7	4	1 GB
   raspi3ap	Cortex-A53	4	512 MiB
   Raspi3b	Cortex-A53	4	1 GB
   
Device support
QEMU provides support for the following devices:

ARM1176JZF-S, Cortex-A7 or Cortex-A53 CPU
Interrupt controller
DMA controller
Clock and reset controller (CPRMAN)
System Timer
GPIO controller
Serial ports (BCM2835 AUX - 16550 based - and PL011)
Random Number Generator (RNG)
Frame Buffer
USB host (USBH)
GPIO controller
SD/MMC host controller
SoC thermal sensor
USB2 host controller (DWC2 and MPHI)
MailBox controller (MBOX)
VideoCore firmware (property)
However, it still lacks support for these:

Peripheral SPI controller (SPI)
Analog to Digital Converter (ADC)
Pulse Width Modulation (PWM)
Set it up
Prerequisites
You will need to have qemu-system-aarch64, you could either build it from source [2] or let your Linux distribution install it for you.

If you are using Arch Linux, then you could use pacman

sudo pacman -Sy qemu-system-aarch64
You will also need to do download and extract the Raspian image you want to use

wget https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-09-26/2022-09-22-raspios-bullseye-arm64-lite.img.xz
unxz 2022-09-22-raspios-bullseye-arm64-lite.img.xz
Loopback mount image
The image could be loopback mounted in order to extract the kernel and devicetree. First we need to figure out the first free loopback device

   sudo losetup -f
   /dev/loop0
Then we could use that device to mount:

   sudo losetup /dev/loop0  ./2022-09-22-raspios-bullseye-armhf-lite.img  -P
The -P option force the kernel to scan the partition table. As the sector size of the image is 512 bytes we could omit the --sector-size.

# Mount the boot partition and root filesystem

   mkdir ./boot ./rootfs
   sudo mount /dev/loop0p1 ./boot/
   sudo mount /dev/loop0p2 ./rootfs/
   
Copy kernel and dtb

   cp boot/bcm2710-rpi-3-b.dtb .
   cp boot/kernel8.img .
   
If you have any modification you want to do on the root filesystem, do it now before we unmount everything.

sudo umount ./boot/
sudo umount ./rootfs/

# Resize image
QEMU requires the image size to be a power of 2, so resize the image to 2GB

   qemu-img resize  ./2022-09-22-raspios-bullseye-armhf-lite.img 2G
Very note that this will lose data if you make the image smaller than it currently is

Wrap it up
Everything is now ready for start QEMU. The parameters are quite self-explained

qemu-system-aarch64 \
    -M raspi3b \
    -cpu cortex-a72 \
    -append "rw earlyprintk loglevel=8 console=ttyAMA0,115200 root=/dev/mmcblk0p2 rootdelay=1" \
    -serial stdio \
    -dtb ./bcm2710-rpi-3-b.dtb \
    -sd ./2022-09-22-raspios-bullseye-armhf-lite.img \
    -kernel kernel8.img \
    -m 1G -smp 4
    
# Here we go

   raspberrypi login: pi
   Password: raspberry
   
   Linux raspberrypi 5.10.103-v8+ #1529 SMP PREEMPT Tue Mar 8 12:26:46 GMT 2022 aarch64

   The programs included with the Debian GNU/Linux system are free software;
   the exact distribution terms for each program are described in the
   individual files in /usr/share/doc/*/copyright.

   Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
   permitted by applicable law.
   pi@raspberrypi:~$


# Raspberry pi 4 b

Not integrated into qemu yet, here is a version of qemu that supports that 
https://github.com/U007D/qemu 

qemu-system-aarch64  \
    -M raspi4b  \
    -kernel kernel8.img \
-append "rw dwc_otg.lpm_enable=0 earlyprintk  loglevel=8 console=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline rootwait ip=192.168.10.2" \
    -d unimp,guest_errors  \
    -trace "bcm*" \
    -sd 2022-09-22-raspios-bullseye-arm64-lite.img \
    -m 4GB -smp 4 \
    -usb -device usb-mouse -device usb-kbd \
	 -device usb-net,netdev=net0 \
	 -netdev user,id=net0,hostfwd=tcp::5555-:22


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



# Bare metal raspi

https://www.rpi4os.com/

Not tested with qemu yet.






  
