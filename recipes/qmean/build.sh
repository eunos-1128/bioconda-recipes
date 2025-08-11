#!/bin/bash
set -exo pipefail

if [[ "${target_platform}" == "linux-"* ]]; then
  export LDFLAGS="-Wl,--allow-shlib-undefined,--export-dynamic -lstdc++"
elif [[ "${target_platform}" == "osx-"* ]]; then
  export LDFLAGS="-undefined dynamic_lookup -Wl,-export_dynamic"
fi

# Build QMEAN
pushd qmean
sed -i.bak 's|${Python_LIBRARIES}||' cmake_support/QMEAN2.cmake

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_CXX_STANDARD=11 \
    -DPython_ROOT_DIR=${PREFIX} \
    -DOST_ROOT=${PREFIX} \
    -DOPTIMIZE=ON
cmake --build build --parallel "${CPU_COUNT}"
cmake --build build --target check --parallel 1
cmake --install build --parallel "${CPU_COUNT}"

# Install docs
pushd doc
make html -j${CPU_COUNT}
mkdir -p ${PREFIX}/share/doc/qmean
cp -r build/html/* ${PREFIX}/share/doc/qmean
popd

# Install wrapper script
install -m 755 docker/run_qmean.py ${PREFIX}/bin/qmean
sed -i.bak \
    -e 's|#!/usr/local/bin/ost|#!/usr/bin/env ost|' \
    -e "s|/usr/local|${PREFIX}|g" \
    -e 's|"/uniclust30"|os.getenv("QMEAN_UNICLUST30")|' \
    -e 's|raise RuntimeError("You must mount UniClust30 to /uniclust30")|raise RuntimeError(f"You must set UniClust30 to {os.getenv(\"QMEAN_UNICLUST30\")}")|' \
    -e 's|"Expect valid UniClust30 to be mounted at /uniclust30. Files "|f"Expect valid UniClust30 to be mounted at {os.getenv(\"QMEAN_UNICLUST30\")}. Files "|' \
    -e 's|# uniclust30 is expected to be mounted at /uniclust30|# uniclust30 is expected to be mounted at `QMEAN_UNICLUST30`|' \
    -e 's|"QMEAN container entry point running\n"||' \
    -e "s|os.getenv('VERSION_QMEAN')|\"${PKG_VERSION}\"|" \
    -e "s|os.getenv('VERSION_OPENSTRUCTURE')|\"${PKG_VERSION_OPENSTRUCTURE}\"|" \
    -e 's|"/qmtl/VERSION"|f"/{os.getenv(\"QMEAN_QMTL\")}/VERSION"|' \
    -e 's|"/qmtl"|os.getenv("QMEAN_QMTL")|' \
    -e 's|/qmtl|`QMEAN_QMTL`|' \
    -e "s|/qmean/predict_ss_sa.pl|os.getenv('CONDA_PREFIX')/sspro/script/predict_ss_sa.pl|" \
    ${PREFIX}/bin/qmean
popd

# Build SSpro and ACCpro
pushd sspro
mkdir -p ${PREFIX}/sspro
sed -i "s|/home/baldig/jianlin/sspro4/|${PREFIX}/sspro|" configure.pl
cp -r * ${PREFIX}/sspro

pushd ${PREFIX}/sspro
perl configure.pl
popd

rm -rf ${PREFIX}/sspro/data/nr \
       ${PREFIX}/sspro/data/big \
       ${PREFIX}/sspro/data/pdb_small \
       ${PREFIX}/sspro/data/pdb_large/old/ \
       ${PREFIX}/sspro/data/pdb_large/new/ \
       ${PREFIX}/sspro/data/blast2.2.8 \
       ${PREFIX}/sspro/data/model/sspro \
       ${PREFIX}/sspro/data/test \
       ${PREFIX}/sspro/data/configure.pl~

patch ${PREFIX}/sspro/script/getACCAligns.pl \
  < ${RECIPE_DIR}/patches/getACCAligns.pl.patch

patch ${PREFIX}/sspro/script/homology_sa.pl \
  < ${RECIPE_DIR}/patches/homology_sa.pl.patch

patch ${PREFIX}/sspro/script/predict_ss_sa.pl \
  < ${RECIPE_DIR}/patches/predict_ss_sa.pl.patch
popd
