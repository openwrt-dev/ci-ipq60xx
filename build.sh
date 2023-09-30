#!/bin/sh
# shellcheck disable=SC3043,SC2086,SC2164,SC2103,SC2046

restore_cache() {
  local src_dir="dl"
  local dst_dir="$BUILD_DIR/dl"
  [ -d $src_dir ] || return 0
  [ -d $dst_dir ] || mkdir -p $dst_dir
  mv ${src_dir}/* $dst_dir
}

save_cache() {
  local src_dir="$BUILD_DIR/dl"
  local dst_dir="dl"
  [ -d $src_dir ] || return 0
  [ -d $dst_dir ] || mkdir -p $dst_dir
  mv ${src_dir}/* $dst_dir
}

get_sources() {
  local repo_url="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY_OWNER}/openwrt-ipq60xx.git"
  local branch="$GITHUB_REF_NAME"
  git clone $repo_url --single-branch -b $branch $BUILD_DIR
}

build_firmware() {
  cd $BUILD_DIR

  ./scripts/feeds update -a
  ./scripts/feeds install -a

  cp ${GITHUB_WORKSPACE}/configs/${BUILD_PROFILE} .config
  make -j$(nproc) V=w || make -j1 V=sc

  cd -
}

package_binaries() {
  local bin_dir="${BUILD_DIR}/bin"
  local tarball="${BUILD_PROFILE}.tar.gz"
  tar -zcvf $tarball -C $bin_dir $(ls $bin_dir -1)
}

get_sources
restore_cache
build_firmware
save_cache
package_binaries
