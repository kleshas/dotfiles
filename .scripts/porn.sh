#!/bin/bash

sudo cryptsetup luksOpen /mnt/4TB/porn/porn.img porn
sudo mount /dev/mapper/porn /mnt/porn

read -p "press key to unmount"

sudo umount /mnt/porn
sudo cryptsetup luksClose /dev/mapper/porn
