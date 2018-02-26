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
elif [ "${PLATFORM}" == "windows64" ]
then
  cmake .. -G "Visual Studio 14 2015 Win64"
elif [ "${PLATFORM}" == "windows32" ]
then
  cmake .. -G "Visual Studio 14 2015 ARM"
elif [ "${PLATFORM}" == "macOS" ]
then
  cmake .. -G "Xcode"
else
  cmake -E env CFLAGS='-O0 -g' cmake ..
fi

cmake --build . --config Release
cd ..


