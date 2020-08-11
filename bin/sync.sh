#!/bin/bash

#script_dir="$(dirname "$(readlink -f "$0")")"
script_dir="$(dirname "$(realpath "$0")")"
arc_dir="$(realpath "${script_dir}/..")"

cd "${arc_dir}"

rm *-factory.img
rm *-sysupgrade.bin
#chmod a-x *
#chmod a+x *.sh

version="$(ls ./R7800-master-*-checksums.txt | sed 's/^\.\///' | sed 's/-checksums.txt//g')"
echo "${version}" > "${arc_dir}/VERSION"

trunc_version="$(echo "${version}" | sed 's/^R7800-master//')"

for file in ./R7800-master-*; do
    trunc_file="$(echo "${file}" | sed 's/'${trunc_version}'//')"
    echo "Renaming \"${file}\" to \"${trunc_file}\""
    mv "${file}" "${trunc_file}"
done