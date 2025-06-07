#!/bin/bash

set -exo pipefail

echo "Building FFTW2..."
cd "${SRC_DIR}"
wget -q https://www.fftw.org/fftw-2.1.5.tar.gz
tar -xzf fftw-2.1.5.tar.gz
cd fftw-2.1.5
./configure --enable-float --enable-shared --prefix="${PREFIX}"
make -j${CPU_COUNT}
make install
cd "${SRC_DIR}"

mkdir -p build && cd build

# CMake設定
cmake .. \
    ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_CXX_STANDARD=17 \
    -DPython_EXECUTABLE="${PYTHON}" \
    -Dnanobind_DIR="${SP_DIR}/nanobind/cmake" \
    -DBOOST_ROOT="${PREFIX}" \
    -DEIGEN3_INCLUDE_DIR="${PREFIX}/include/eigen3" \
    -DGSL_ROOT_DIR="${PREFIX}" \
    -DRDKIT_ROOT="${PREFIX}"

echo "Building Coot Headless API..."
cmake --build . --target coot_headless_api --parallel ${CPU_COUNT}

echo "Installing Coot Headless API..."
cmake --install .
