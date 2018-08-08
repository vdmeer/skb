#!/bin/env bash

attributes=""

if [ "$1" == "-l" ]; then
    attributes="-a local=true"
fi


echo "  building library with attributes: $attributes"
for file in `ls *.adoc`
do
    echo "  -> ${file%.*}"
    asciidoctor $file -a toc=left $attributes
    chmod 644 ${file%.*}.html
done


if [ "$1" == "-l" ]; then
    echo "  publish to local library"
    (rm -f ../../../../library/*.html)
    cp *.html ../../../../library
else
    echo "  publish to vdmeer.github.io repo"
    rm -fr ../../vdmeer.github.io/library/*
    cp *.html ../../vdmeer.github.io/library/
    #rsync -a --prune-empty-dirs --include '*/' --include '*.html' --exclude '*' . ../../vdmeer.github.io/library/
fi


echo "  clean up"
rm *.html >& /dev/null
echo "  done"
