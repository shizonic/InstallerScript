#!/bin/bash

# test if any package missing , if so remove from list

##find lines only in file1
#comm -23 file1 file2 
#
##find lines only in file2
#comm -13 file1 file2 
#
##find lines common to both files
#comm -12 file1 file2 


#define Packages
#Packages=(neovim nvim fireffox polybar gnome-terminal)
Packages=(neofetch firefox ffox curl xorg-apps )
AsDeps=(curl)
#print Packages to file
#printf "%s\n" "${Packages[@]}" > needed_pkg_list

# list missing Packages
#missings=(`comm -23 <(sort -u needed_pkg_list) <(sort -u <(curl -s https://aur.archlinux.org/Packages.gz | gunzip) <(pacman -Ssq))`)
Missings=( $(comm -23 <(echo "${Packages[@]}" | tr ' ' '\n' | sort -u) <(sort -u <(curl -s https://aur.archlinux.org/packages.gz | gunzip) <(pacman -Ssq) <(pacman -Sgq))) )

#printf "%s\n" "${Missings[@]}" > missing_Packages.txt


Packages=( $(comm -23 <(echo "${Packages[@]}" | tr ' ' '\n' | sort -u) <(echo "${Missings[@]}" | tr ' ' '\n' | sort -u)) )
AsDeps=( $(comm -23 <(echo "${AsDeps[@]}" | tr ' ' '\n' | sort -u) <(echo "${Missings[@]}" | tr ' ' '\n' | sort -u)) )

echo "Missing Number: ${#Missings[@]}"
echo "${Missings[@]}"
#echo "${Packages[@]}"
#echo "${AsDeps[@]}"

#tests=(`comm -3 <(sort -u needed_pkg_list) <(sort -u missing_Packages.txt)`)
#printf "%s\n" "${tests[@]}" > cmis
#echo ${tests[@]}

