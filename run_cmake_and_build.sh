#!/bin/bash

PLATFORM=$1
PRE=""
INSTALL_PREFIX=install

if [ "${PLATFORM}" != "android" ]
then
  BUILD_DIR=.build_$PLATFORM
  rm -rf $BUILD_DIR
  mkdir -p $BUILD_DIR
  cd $BUILD_DIR
fi

if [ "${PLATFORM}" == "emscripten" ]
then
  export EMCC_DEBUG=1 # Verbose building...
  emcmake cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}
elif [ "${PLATFORM}" == "windows64" ]
then
  cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -G "Visual Studio 14 2015 Win64"
elif [ "${PLATFORM}" == "windows32" ]
then
  cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -G "Visual Studio 14 2015"
elif [ "${PLATFORM}" == "macOS" ]
then
  cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -G "Xcode"
elif [ "${PLATFORM}" == "ios" ]
then
  cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -G "Xcode" -DIOS:BOOL=TRUE
elif [ "${PLATFORM}" == "appletv" ]
then
  cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -G "Xcode" -DTVOS:BOOL=TRUE
elif [ "${PLATFORM}" == "android" ]
then
  cd android
  ./gradlew assembleDebug
else
  cmake -E env CFLAGS='-O0 -g' cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}
fi

cmake --build . --config Release --target install

if [ "${PLATFORM}" == "emscripten" ]
then
  emcmake cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}
  cmake --build . --config Release --target install
fi

cd ..
