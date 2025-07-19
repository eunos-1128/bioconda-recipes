#!/bin/bash

set -exo pipefail

export CFLAGS="${CFLAGS} -include stdlib.h"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ "${build_platform}" == "linux-"* ]]; then
    export CXXFLAGS="${CXXFLAGS} -fopenmp"
    export LDFLAGS="${LDFLAGS} -fopenmp"
elif
    [[ "${build_platform}" == "osx-"* ]]; then
    export CXXFLAGS="${CXXFLAGS} -Xpreprocessor -fopenmp"
    export LDFLAGS="${LDFLAGS} -lomp"
fi

sed -i.bak 's|python bootstrap.py --builder=molprobity --use-conda $nproc||' install_via_bootstrap.sh
sed -i.bak 's|echo ++++++++++ MolProbity configure.sh finished.||' install_via_bootstrap.sh
sed -i.bak 's|echo ++++++++++ Run molprobity/setup.sh to complete installation.||' install_via_bootstrap.sh

chmod +x install_via_bootstrap.sh
./install_via_bootstrap.sh "${CPU_COUNT}"

sed -i.bak '/^from __future__ import absolute_import, division, print_function/a\
import os\
os.environ.setdefault("CPPFLAGS", "")\
os.environ["CPPFLAGS"] += " -include stdlib.h"\
' bootstrap.py

"${PYTHON}" bootstrap.py \
    --download-only \
    --builder=molprobity \
    --use-conda="${PREFIX}" \
    --nproc="${CPU_COUNT}"

sed -i.bak 's|int putenv ();||' modules/ccp4io/libccp4/ccp4/library_utils.c
sed -i.bak 's|^int routne.*;||' modules/ccp4io/libccp4/fortran/library_f.c

"${PYTHON}" bootstrap.py \
    --mpi-build \
    --no-boost-src \
    --enable-shared \
    --builder=molprobity \
    --with-python="${PYTHON}" \
    --use-conda="${PREFIX}" \
    --nproc="${CPU_COUNT}" \
    build tests doc
