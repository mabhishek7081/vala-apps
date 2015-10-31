#!/bin/bash
# 
# Author: simargl <https://github.com/simargl>
# License: GPL v3

for i in $(find . -maxdepth 1 -mindepth 1 -type d -not -path '*/\.*' -not -name screenshots | sort); do 
    cd $i
    if [ -d po ]; then
        xgettext --language=C --keyword=_ --escape --sort-output -o po/$i.pot src/*.vala
        # po files
        for l in $(find po -name *.po); do msgmerge -s -U $l po/$i.pot; done
    fi
    cd ..
done
