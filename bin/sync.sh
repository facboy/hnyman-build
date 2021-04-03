#!/bin/bash

if [[ $#  -ne 1 ]]; then
    >&2 echo "$0 <zip file>"
    exit 255
fi

#script_dir="$(dirname "$(readlink -f "$0")")"
script_dir="$(dirname "$(realpath "$0")")"
arc_dir="$(realpath "${script_dir}/..")"

function normalize_dir() {
    local tmp_dir="$1"
    cd "${tmp_dir}"

    rm *-factory.img
    rm *-sysupgrade.bin
    rm *.ipk
    chmod a-x *
    chmod a+x *.sh

    local version="$(ls ./R7800-master-*-checksums.txt | sed 's/^\.\///' | sed 's/-checksums.txt//g')"
    echo "${version}" > "${tmp_dir}/VERSION"

    local trunc_version="$(echo "${version}" | sed 's/^R7800-master//')"

    for file in ./R7800-master-*; do
        local trunc_file="$(echo "${file}" | sed 's/'${trunc_version}'//')"
        echo "Renaming \"${file}\" to \"${trunc_file}\""
        mv "${file}" "${trunc_file}"
    done

    dos2unix "./R7800-master-checksums.txt"
    dos2unix "./R7800-master-status.txt"
}

# extract zip and normalize contents
temp_dir="$(mktemp -d)"
unzip "$1" -d"${temp_dir}" 
normalize_dir "${temp_dir}"

# update git archive dir
cp "${temp_dir}/"* "${arc_dir}/"

# commit
cd "${arc_dir}"
version="$(cat VERSION)" 
git add *
git commit -m "Update to version ${version}"
