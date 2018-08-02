#!/bin/env bash

attributes=""

if [ "$1" == "-l" ]; then
    attributes="-a local=true"
fi

echo "  start building library with attributes: $attributes"
for file in `ls *.adoc`
do
    echo "  -> ${file%.*}"
    asciidoctor $file -a toc=left $attributes
    chmod 644 ${file%.*}.html
done
echo "  done"
