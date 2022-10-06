#!/bin/bash

if [[ $#  -ne 1 ]]; then
    >&2 echo "$0 <openwrt git root>"
    exit 255
fi

set -ex

script_dir="$(dirname "$(realpath "$0")")"

# get commit message
cd "${script_dir}/../"
COMMIT_MESSAGE="$(git log --format='tformat:%s' | grep "Update to version R7800-master-" | head -n1)"

OPENWRT_ROOT="$1"
cd "${OPENWRT_ROOT}"

# reset master
# Compile_info always has some junk in it
COMPILE_INFO="files/etc/Compile_info.txt"
if [[ -e "${COMPILE_INFO}" ]]; then
	git restore --staged --worktree "${COMPILE_INFO}"
fi
git fetch upstream
git co hnyman-build-apply
git reset --hard upstream/master

${script_dir}/apply_main.sh
git add ".gitignore" ".config.init" "feeds.conf.default" "files/" "hnscripts/" \
	"package/base-files/" "package/network/" "package/utils/busybox/" \
	"target/linux/ipq806x/base-files/etc/"
git commit -m "${COMMIT_MESSAGE}"

# reset luci
cd "${OPENWRT_ROOT}/feeds/luci"
git fetch upstream
git co hnyman
git reset --hard upstream/master
# script expects to be run from OPENWRT_ROOT
(cd ${OPENWRT_ROOT} && ${script_dir}/apply_luci.sh)
git add "applications/" "modules/" "themes/"
git commit -m "${COMMIT_MESSAGE}"
git push -f

# reset packages
cd "${OPENWRT_ROOT}/feeds/packages"
git fetch upstream
git co hnyman
git reset --hard upstream/master
# script expects to be run from OPENWRT_ROOT
(cd ${OPENWRT_ROOT} && ${script_dir}/apply_packages.sh)
git add "net/adblock/" "net/bcp38/" "net/sqm-scripts/"
git commit -m "${COMMIT_MESSAGE}"
git push -f

# update other feeds
for feed in "routing" "telephony"; do
	cd "${OPENWRT_ROOT}/feeds/${feed}"
	git pull origin master
done
