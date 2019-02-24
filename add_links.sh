#!/bin/bash
# Parameters:
# $1 -> folder
# $2 -> filename prefix
#
# Add links for filenames starting using '-' as delimiter
# ie ar -> llvm-ar

pushd $1
for filename in $2*; do
  short_name=$(echo $filename | rev | cut -d- -f1 | rev)
  ln -s $filename $short_name
done 
popd
