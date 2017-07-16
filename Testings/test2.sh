#!/bin/bash

IFS=$' '
res="a b c"
for x in $res; do
    echo "$x"
done
