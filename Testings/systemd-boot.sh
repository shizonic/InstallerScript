#!/bin/bash
cat > arch.conf <<EOF
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options root=PARTUUID=`sudo blkid -s PARTUUID -o value /dev/sda2` rw
EOF
