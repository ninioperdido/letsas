#!/bin/sh
pandoc $1 metadata.yaml -s -S -o ${1%.*}.pdf


