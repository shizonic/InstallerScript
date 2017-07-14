#!/bin/bash

# test if any package missing , if so remove from list

#define packages
packages=(neovim nvim fireffox polybar gnome-terminal)

#print packages to file
printf "%s\n" "${packages[@]}" > needed_pkg_list

# list missing packages
missings=(`comm -23 <(sort -u needed_pkg_list) <(sort -u <(curl -s https://aur.archlinux.org/packages.gz | gunzip) <(pacman -Ssq))`)

printf "%s\n" "${missings[@]}" > missing_packages.txt

