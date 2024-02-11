#
# flash-kernel: boot.cmd
#

# Ubuntu Classic RPi U-Boot script (for armhf and arm64)

# Expects to be called with the following environment variables set:
#
#  devtype              e.g. mmc/scsi etc
#  devnum               The device number of the given type
#  distro_bootpart      The partition containing the boot files
#                       (introduced in u-boot mainline 2016.01)
#  prefix               Prefix within the boot partiion to the boot files
#  kernel_addr_r        Address to load the kernel to
#  fdt_addr_r           Address to load the FDT to
#  ramdisk_addr_r       Address to load the initrd to.

echo "Select Kernel Version:"
echo "1. Rpi 4, framebuffer"
echo "2. Mini uart"
echo "3. Kernel"
echo "Enter your choice (1-3): "
setenv choice
while test -z "$choice"
do
    read choice
done

if test "$choice" = "1"; then
    echo "Booting Kernel Version 1..."
    setenv bootargs 'set your bootargs here'
    fatload mmc 0:1 ${kernel_addr_r} /boot/framebuffer.elf
    bootm ${kernel_addr_r}
elif test "$choice" = "2"; then
    echo "Booting Kernel Version 2..."
    setenv bootargs 'set your bootargs here'
    fatload mmc 0:1 ${kernel_addr_r} /boot/miniuart.elf
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
