#!/bin/env bash

rm -fr ../../vdmeer.github.io/library/*
#rsync -a --prune-empty-dirs --include '*/' --include '*.html' --exclude '*' . ../../vdmeer.github.io/library/
cp *.html ../../vdmeer.github.io/library/
