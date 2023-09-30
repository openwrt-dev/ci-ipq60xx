#!/bin/sh
# shellcheck disable=SC3043,SC2086,SC2164,SC2103,SC2046

get_sources() {
  local repo_url="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY_OWNER}/openwrt-ipq60xx.git"
  local branch="$GITHUB_REF_NAME"
  git clone $repo_url --single-branch -b $branch openwrt
}

build_firmware() {
  cd openwrt

  ./scripts/feeds update -a
  ./scripts/feeds install -a

  cp ${GITHUB_WORKSPACE}/configs/${BUILD_PROFILE} .config
  make -j$(nproc) V=w || make -j1 V=sc

  cd -
}

package_binaries() {
  local bin_dir="openwrt/bin"
  local tarball="${BUILD_PROFILE}.tar.gz"
  tar -zcvf $tarball -C $bin_dir $(ls $bin_dir -1)
}

get_sources
build_firmware
package_binaries
