#!/bin/bash

MIRROR=Worldwide

# vim in normal mode
nvim -s <(printf "/%s\n{}d\e:wq! mirrorlist.txt\n" "$MIRROR") <(curl -s https://www.archlinux.org/mirrorlist/all/)
