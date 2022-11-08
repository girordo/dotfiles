#!/bin/bash

PARAMS=('-m 6 -q 80 -mt -af -progress')

if [ $# -ne 0 ]; then
        PARAMS=$@;
fi

cd $(pwd)

shopt -s nullglob nocaseglob extglob

for FILE in *.@(jpg|jpeg|tif|tiff|png); do
    if [ ! -f "${FILE%.*}".webp ]; then 
       cwebp $PARAMS "$FILE" -o "${FILE%.*}".webp;
    fi
done
