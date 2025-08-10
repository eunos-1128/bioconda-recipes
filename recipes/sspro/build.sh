#!/bin/bash

# Fix installation dir
sed -i "s|/home/baldig/jianlin/sspro4/|${PREFIX}|g" configure.pl
perl configure.pl

rm -rf $PREFIX/data/nr $PREFIX/data/big \
       $PREFIX/data/pdb_small \
       $PREFIX/data/pdb_large/old/ \
       $PREFIX/data/pdb_large/new/ \
       $PREFIX/data/blast2.2.8 \
       $PREFIX/data/model/sspro \
       $PREFIX/data/test \
       $PREFIX/data/configure.pl~
