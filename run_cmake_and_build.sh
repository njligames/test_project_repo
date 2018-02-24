#!/bin/bash

PLATFORM=$1
PRE=""

BUILD_DIR=.build_$PLATFORM
rm -rf $BUILD_DIR
mkdir $BUILD_DIR
cd $BUILD_DIR

git clone git@github.com:njligames/test_engine_repo.git

if [ "${PLATFORM}" == "emscripten" ]
then
  emcmake cmake ..
else
  cmake -E env CFLAGS='-O0 -g' cmake ..
fi

make
cd ..

