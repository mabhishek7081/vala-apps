#!/bin/bash
# 
# Author: simargl <https://github.com/simargl>
# License: GPL v3

for i in $(find . -maxdepth 1 -mindepth 1 -type d -not -path '*/\.*' -not -name screenshots | sort); do 
    cd $i/src
    astyle *.vala --style=google --delete-empty-lines --add-brackets --max-code-length=80 --suffix=none 
    cd ../..
done
