#!/bin/bash
# 
# Author: simargl <https://github.com/simargl>
# License: GPL v3

for i in $(find . -maxdepth 1 -mindepth 1 -type d -not -path '*/\.*' -not -name screenshots | sort); do 
    cd $i; mkdir build; cd build; meson --prefix=/usr --buildtype=plain; DESTDIR=/tmp/1 ninja install; cd ..; rm -r build; cd ..;
done

elfedit --input-type=dyn --output-type=exec /tmp/1/usr/bin/*

mksquashfs /tmp/1 vala-apps.sb
