#!/bin/bash

#script_dir="$(dirname "$(readlink -f "$0")")"
script_dir="$(dirname "$(realpath "$0")")"

. ${script_dir}/apply_common.sh

(cd feeds/packages; patch -p1 -i ${arc_dir}/$FILESTAMP-packages.patch)
