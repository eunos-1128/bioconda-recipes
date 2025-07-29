#!/bin/bash

set -exo pipefail

# export CFLAGS="${CFLAGS} -include stdlib.h"
# export CXXFLAGS="${CXXFLAGS} -O3"

# if [[ "${build_platform}" == "linux-"* ]]; then
#     export CXXFLAGS="${CXXFLAGS} -fopenmp"
#     export LDFLAGS="${LDFLAGS} -fopenmp"
# elif
#     [[ "${build_platform}" == "osx-"* ]]; then
#     export CXXFLAGS="${CXXFLAGS} -Xpreprocessor -fopenmp"
#     export LDFLAGS="${LDFLAGS} -lomp"
# fi

# sed -i.bak 's|python bootstrap.py --builder=molprobity --use-conda $nproc||' install_via_bootstrap.sh
# sed -i.bak 's|echo ++++++++++ MolProbity configure.sh finished.||' install_via_bootstrap.sh
# sed -i.bak 's|echo ++++++++++ Run molprobity/setup.sh to complete installation.||' install_via_bootstrap.sh

# chmod +x install_via_bootstrap.sh
# ./install_via_bootstrap.sh "${CPU_COUNT}"

# sed -i.bak '/^from __future__ import absolute_import, division, print_function/a\
# import os\
# os.environ.setdefault("CPPFLAGS", "")\
# os.environ["CPPFLAGS"] += " -include stdlib.h"\
# ' bootstrap.py

# "${PYTHON}" bootstrap.py \
#     --download-only \
#     --builder=molprobity \
#     --use-conda="${PREFIX}" \
#     --nproc="${CPU_COUNT}"

# sed -i.bak 's|int putenv ();||' modules/ccp4io/libccp4/ccp4/library_utils.c
# sed -i.bak -E \
#   's|\(void[[:space:]]*\(\*[[:space:]]*routne\)[[:space:]]*\(\)[[:space:]]*,|(void (* routne)(...),|g' \
#   modules/ccp4io/libccp4/fortran/library_f.c

# "${PYTHON}" bootstrap.py \
#     --mpi-build \
#     --no-boost-src \
#     --enable-shared \
#     --builder=molprobity \
#     --with-python="${PYTHON}" \
#     --use-conda="${PREFIX}" \
#     --nproc="${CPU_COUNT}" \
#     base build tests doc

mkdir -p "${PREFIX}/bin"
if [[ "${target_platform}" == "linux-"* ]]; then
    for dir in bin "bin/linux"; do
        for f in "${SRC_DIR}/${dir}/"*; do
            [[ -f "$f" ]] && install -m 755 "$f" "${PREFIX}/bin"
        done
    done
elif [[ "${target_platform}" == "osx-"* ]]; then
    for dir in bin "bin/macosx"; do
        for f in "${SRC_DIR}/${dir}/"*; do
            [[ -f "$f" ]] && install -m 755 "$f" "${PREFIX}/bin"
        done
    done
fi

mkdir -p "${PREFIX}/libexec/molprobity"/{cmdline,lib,jobs,config}
for dir in cmdline config jobs lib; do
    for f in "${SRC_DIR}/${dir}/"*; do
        [[ -f "$f" ]] && install -m 755 "$f" "${PREFIX}/libexec/molprobity/${dir}"
    done
done

pushd "${PREFIX}/bin" >/dev/null
for tool in ../libexec/molprobity/cmdline/*; do
    [[ -f "$tool" ]] || continue
    ln -s "$tool" "$(basename "$tool")"
done
popd >/dev/null
