#!/bin/bash

PLATFORM=$1
PRE=""

if [ "${PLATFORM}" != "android" ]
then
  BUILD_DIR=.build_$PLATFORM
  rm -rf $BUILD_DIR
  mkdir $BUILD_DIR
  cd $BUILD_DIR
fi

if [ "${PLATFORM}" == "emscripten" ]
then
  emcmake cmake ..
elif [ "${PLATFORM}" == "windows64" ]
then
  cmake .. -G "Visual Studio 14 2015 Win64"
elif [ "${PLATFORM}" == "windows32" ]
then
  cmake .. -G "Visual Studio 14 2015"
elif [ "${PLATFORM}" == "macOS" ]
then
  cmake .. -G "Xcode"
elif [ "${PLATFORM}" == "ios" ]
then
  cmake .. -G "Xcode" -DIOS:BOOL=TRUE
elif [ "${PLATFORM}" == "appletv" ]
then
  cmake .. -G "Xcode" -DTVOS:BOOL=TRUE
elif [ "${PLATFORM}" == "android" ]
then
  cd android
  ./gradlew assembleDebug
else
  cmake -E env CFLAGS='-O0 -g' cmake ..
fi

cmake --build . --config Release
cd ..



