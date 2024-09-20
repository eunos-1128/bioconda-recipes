#!/bin/bash

set -exo pipefail

# Disable parallel build
export CPU_COUNT=1


ln -s "${BUILD_PREFIX}/bin/aarch64-conda-linux-gnu-gcc" "${BUILD_PREFIX}/bin/gcc"
ln -s "${BUILD_PREFIX}/bin/aarch64-conda-linux-gnu-g++" "${BUILD_PREFIX}/bin/g++"

make binary "-j${CPU_COUNT}"

unlink "${BUILD_PREFIX}/bin/gcc"
unlink "${BUILD_PREFIX}/bin/g++"

install -d "${PREFIX}/bin"
install ${SRC_DIR}/bin/* "${PREFIX}/bin"
cp -r "${SRC_DIR}/data" "${PREFIX}/data"
