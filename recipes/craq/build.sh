#!/bin/sh
set -x -e

# As CRAQ does not use standard packaging approach (Makefile.PL, Build.PL, ...), we need to keep CRAQ and its modules all together at the same place.
# So CRAQ is copied in the share folder with all related modules (copy of the repo)
CRAQ_DIR=${PREFIX}/share/CRAQ
mkdir -p ${CRAQ_DIR}
cp -r * ${CRAQ_DIR}
chmod +x ${CRAQ_DIR}/bin/craq

# Add the craq executable in the bin by softlinking the tool located in share.
mkdir -p ${PREFIX}/bin
ln -s ${CRAQ_DIR}/bin/craq ${PREFIX}/bin/craq

# Add the `src` folder with scripts that are called by the main `craq` executable with a relative path
mkdir -p ${PREFIX}/src
for fn in ${CRAQ_DIR}/src/*; do
  bn=$(basename $fn)
  ln -s $fn ${PREFIX}/src/${bn}
done
