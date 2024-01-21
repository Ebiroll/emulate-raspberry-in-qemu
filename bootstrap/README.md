
# Install ubuntu from WSL

More info here,
https://wiki.archlinux.org/title/QEMU

# Install WSL

Alpine,  apk add qemu qemu-img qemu-system-x86_64 qemu-ui-gtk

Clipboard sharing spice-vdagent

Ubuntu,

Check kvm
cat /proc/cpuinfo

vmx flags       : vnmi invvpid ept_x_only ept_ad ept_1gb tsc_offset vtpr ept vpid unrestricted_guest ept_mode_based_exec tsc_scaling usr_wait_pause


# Install VM

You might want to get Lubuntu https://lubuntu.me/downloads/

cp /mnt/c/Users/XXX/Downloads/ubuntu-22.04.3-desktop-amd64.iso .

qemu-img create -f qcow2 Ubuntu-disk.img 20G

qemu-system-x86_64 -enable-kvm -cdrom ubuntu-XXX.iso -boot menu=on -drive file=Ubuntu-disk.img -m 4G -cpu host -display gtk

#  Other useful setting -vga virtio

# Running ubuntu,

qemu-system-x86_64 -enable-kvm -drive file=Ubuntu-disk.img -m 4G -cpu host -display gtk


If you do not have the kvm  support in kernel  omit enable-kvm 



# Encryption

https://cloud.ibm.com/docs/vpc?topic=vpc-create-encrypted-custom-image


qemu-img create --object secret,id=sec0,data=abc123 -f qcow2 -o encrypt.format=luks,encrypt.key-secret=sec0 encrypted.qcow2 10G

qemu-img info


# Share filesystem

virtio-fs

# Alpine
  apk add guestfs-tools@testing



Alpine  info

https://wiki.alpinelinux.org/wiki/QEMU





https://forums.raspberrypi.com/viewtopic.php?t=206630




Ubuntu qemu
https://www.makeuseof.com/install-ubuntu-virtual-machine-with-qemu/
