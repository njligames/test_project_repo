#!/bin/bash

# To build android make sure that ANDROID_HOME environment variable is set.

PLATFORM=$1
BOT=$2
CONFIGURATION=Debug
# CONFIGURATION=Release
PRE=""
INSTALL_PREFIX=install

EXECUTABLE_NAME=PLACEHOLDER
EXECUTABLE_GITHUB_REPOSITORY=njligames-njlic_engine
EXECUTABLE_GITHUB_BRANCH=master
EXECUTABLE_GITHUB_ACCOUNT=njligames

if [ "${PLATFORM}" != "android" ]
then
  BUILD_DIR=.build_$PLATFORM
  if [ -z "$BOT" ]
  then
    rm -rf $BUILD_DIR
  else
    BUILD_DIR=bot_$PLATFORM
    rm $BUILD_DIR/CMakeCache.txt
    rm -rf $BUILD_DIR/CMakeScripts/
    rm -rf $BUILD_DIR/NJLIC*
    rm $BUILD_DIR/njligames-njlic_engine/swig/lua/*.c*

    # BUILD_DIR=NJLIC_${PLATFORM}_Robot
    # rm $BUILD_DIR/CMakeCache.txt
    # rm -rf $BUILD_DIR/CMakeScripts/
    # rm -rf $BUILD_DIR/NJLIC*
    
  fi

  mkdir -p $BUILD_DIR
  cd $BUILD_DIR
fi

if [ "${PLATFORM}" == "emscripten" ]
then
  # export CC=/usr/bin/cc
  # export CXX=/usr/bin/c++

  # export EMSCRIPTEN_VERSION=1.37.9
  # export EMSCRIPTEN_VERSION=1.38.10
  # export EMSCRIPTEN_LOCATION=/Users/jamesfolk/Work/tools/emsdk/emscripten/${EMSCRIPTEN_VERSION}
  # export EMSCRIPTEN_INCLUDE_LOCATION=${EMSCRIPTEN_LOCATION}/system/include


  # export EMCC_DEBUG=1 # Verbose building...
  # export VERBOSE=1

  emcmake cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
  -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
  -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
  -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
  -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
  -G "Ninja" 
  
elif [ "${PLATFORM}" == "facebook" ]
then

  emcmake cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
  -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
  -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
  -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
  -DFACEBOOK-APP-ID="344740292600474" \
  -DFACEBOOK-API-VERSION="v2.12" \
  -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
  -DFACEBOOK:BOOL=TRUE \
  -G "Ninja"

elif [ "${PLATFORM}" == "windows64" ]
then

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -G "Visual Studio 14 2015 Win64"

elif [ "${PLATFORM}" == "windows32" ]
then

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -G "Visual Studio 14 2015"

elif [ "${PLATFORM}" == "macOS" ]
then

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -G "Xcode"

elif [ "${PLATFORM}" == "linux" ]
then
  export CC=/usr/bin/cc
  export CXX=/usr/bin/c++

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -G "Unix Makefiles"

elif [ "${PLATFORM}" == "ios" ]
then

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -G "Xcode" \
    -DIOS:BOOL=TRUE

elif [ "${PLATFORM}" == "appletv" ]
then

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -G "Xcode" \
    -DTVOS:BOOL=TRUE

elif [ "${PLATFORM}" == "android" ]
then

  rm -rf android/app/.externalNativeBuild

  cd android
  ./gradlew clean
  ./gradlew assemble${CONFIGURATION}
  ./gradlew install${CONFIGURATION}

elif [ "${PLATFORM}" == "oculus_windows64" ]
then

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DOCULUS=TRUE \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -G "Visual Studio 14 2015 Win64"

elif [ "${PLATFORM}" == "oculus_windows32" ]
then

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DOCULUS=TRUE \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -G "Visual Studio 14 2015"

elif [ "${PLATFORM}" == "oculus_macOS" ]
then

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DOCULUS=TRUE \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -G "Xcode"

elif [ "${PLATFORM}" == "vr_ios" ]
then

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DVR=TRUE \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -G "Xcode" \
    -DIOS:BOOL=TRUE

else
  cmake -E env CFLAGS='-O0 -g' cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}
fi

cmake --build . --target clean
cmake --build . --config ${CONFIGURATION} # --target install

cd ..
