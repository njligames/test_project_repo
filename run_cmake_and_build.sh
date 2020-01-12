#!/bin/bash

# To build android make sure that ANDROID_HOME environment variable is set.

PLATFORM=$1
BOT=$2
INSTALL_TARGET=install
# CONFIGURATION=Debug
#CONFIGURATION=MinSizeRel
CONFIGURATION=Release
# CONFIGURATION=RelWithDebInfo

PRE=""
INSTALL_PREFIX=install/${CONFIGURATION}

EXECUTABLE_NAME=YappyBirds
EXECUTABLE_GITHUB_REPOSITORY=njligames-njlic_engine
EXECUTABLE_GITHUB_BRANCH=project/yappybirds
EXECUTABLE_GITHUB_ACCOUNT=njligames

if  [ "${PLATFORM}" != "android" ] &&  [ "${PLATFORM}" != "vr_android" ]
then
  BUILD_DIR=.build_$PLATFORM
  if [ -z "$BOT" ]
  then
    rm -rf $BUILD_DIR
  else
    BUILD_DIR=buildbot_$PLATFORM

    rm $BUILD_DIR/CMakeCache.txt
    rm -rf $BUILD_DIR/CMakeScripts/
    rm -rf $BUILD_DIR/NJLIC*
    rm -rf $BUILD_DIR/${INSTALL_PREFIX}

  fi

  mkdir -p $BUILD_DIR
  cd $BUILD_DIR
fi

if [ "${PLATFORM}" == "emscripten" ]
then

  emcc -v
  emcc --clear-cache
  emcmake cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
  -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
  -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
  -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
  -DCMAKE_BUILD_TYPE=${CONFIGURATION} \
  -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
  -DEMBED_ASSETS:BOOL=TRUE \
  -G "Ninja"

elif [ "${PLATFORM}" == "facebook" ]
then

  emcc -v
  emcc --clear-cache
  emcmake cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
  -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
  -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
  -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
  -DCMAKE_BUILD_TYPE=${CONFIGURATION} \
  -DFACEBOOK-APP-ID="2608719869359117" \
  -DFACEBOOK-API-VERSION="v2.8" \
  -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
  -DFACEBOOK:BOOL=TRUE \
  -G "Ninja"

elif [ "${PLATFORM}" == "windows64" ]
then

  INSTALL_TARGET=PACKAGE.vcxproj

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DCMAKE_BUILD_TYPE=${CONFIGURATION} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
    -G "Visual Studio 16 2019" -A "x64"

elif [ "${PLATFORM}" == "windows32" ]
then

  INSTALL_TARGET=PACKAGE.vcxproj

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DCMAKE_BUILD_TYPE=${CONFIGURATION} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
    -G "Visual Studio 16 2019" -A "Win32"

elif [ "${PLATFORM}" == "macOS" ]
then

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DCMAKE_BUILD_TYPE=${CONFIGURATION} \
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
    -DCMAKE_BUILD_TYPE=${CONFIGURATION} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -G "Ninja"

elif [ "${PLATFORM}" == "raspberry" ]
then
  export CC=/usr/bin/cc
  export CXX=/usr/bin/c++

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -G "Unix Makefiles" \
    -DRASPBERRYPI:BOOL=TRUE

elif [ "${PLATFORM}" == "ios" ]
then

  cmake .. \
    -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} \
    -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} \
    -DEXECUTABLE_GITHUB_BRANCH:STRING=${EXECUTABLE_GITHUB_BRANCH} \
    -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} \
    -DCMAKE_BUILD_TYPE=${CONFIGURATION} \
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
    -DCMAKE_BUILD_TYPE=${CONFIGURATION} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -G "Xcode" \
    -DTVOS:BOOL=TRUE

elif [ "${PLATFORM}" == "android" ]
then

  rm -rf buildbot_android/app/.externalNativeBuild

  cd buildbot_android
  ./gradlew clean
  ./gradlew assemble${CONFIGURATION}
  ./gradlew install${CONFIGURATION}

elif [ "${PLATFORM}" == "vr_android" ]
then

  rm -rf buildbot_vr_android/app/.externalNativeBuild

  cd buildbot_vr_android
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
    -DCMAKE_BUILD_TYPE=${CONFIGURATION} \
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
    -DCMAKE_BUILD_TYPE=${CONFIGURATION} \
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
    -DCMAKE_BUILD_TYPE=${CONFIGURATION} \
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
    -DCMAKE_BUILD_TYPE=${CONFIGURATION} \
    -DVR=TRUE \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -G "Xcode" \
    -DIOS:BOOL=TRUE

else
  cmake -E env CFLAGS='-O0 -g' cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}
fi

cmake --build . --config ${CONFIGURATION} --target ${INSTALL_TARGET}

if [ "${PLATFORM}" == "ios" ] || [ "${PLATFORM}" == "vr_ios" ]
then
  cpack -C ${CONFIGURATION}-iphoneos
elif [ "${PLATFORM}" == "appletv" ]
then
  cpack -C ${CONFIGURATION}-appletvos
else
  cpack -C ${CONFIGURATION}
fi

cd ..
