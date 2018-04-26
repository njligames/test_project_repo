#!/bin/bash

PLATFORM=$1
PRE=""
INSTALL_PREFIX=install

EXECUTABLE_NAME=PLACEHOLDER
EXECUTABLE_GITHUB_REPOSITORY=njligames-njlic_engine
EXECUTABLE_GITHUB_ACCOUNT=njligames

if [ "${PLATFORM}" != "android" ]
then
  BUILD_DIR=.build_$PLATFORM
  # BUILD_DIR=bot_$PLATFORM
  # rm -rf $BUILD_DIR
  # rm $BUILD_DIR/CMakeCache.txt
  mkdir -p $BUILD_DIR
  cd $BUILD_DIR
fi

if [ "${PLATFORM}" == "emscripten" ]
then
  export EMCC_DEBUG=1 # Verbose building...
  emcmake cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}
elif [ "${PLATFORM}" == "facebook" ]
then
  emcmake cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} -DFACEBOOK-APP-ID="344740292600474" -DFACEBOOK-API-VERSION="v2.12" -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DFACEBOOK:BOOL=TRUE
elif [ "${PLATFORM}" == "windows64" ]
then
  cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -G "Visual Studio 14 2015 Win64"
elif [ "${PLATFORM}" == "windows32" ]
then
  cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -G "Visual Studio 14 2015"
elif [ "${PLATFORM}" == "macOS" ]
then
  cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -G "Xcode"
elif [ "${PLATFORM}" == "ios" ]
then
  cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -G "Xcode" -DIOS:BOOL=TRUE
elif [ "${PLATFORM}" == "appletv" ]
then
  cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -G "Xcode" -DTVOS:BOOL=TRUE
elif [ "${PLATFORM}" == "android" ]
then
  # /Users/jamesfolk/Documents/NJLI/TESTBED/test_project_repo/android/app/.externalNativeBuild/cmake/release/arm64-v8a/cmake.in/platform.in/android/res
  # /Users/jamesfolk/Documents/NJLI/TESTBED/test_project_repo/android/app/src/main/res

  cd android
  ./gradlew assembleDebug
elif [ "${PLATFORM}" == "oculus_windows64" ]
then
  cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} -DOCULUS=TRUE -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -G "Visual Studio 14 2015 Win64"
elif [ "${PLATFORM}" == "oculus_windows32" ]
then
  cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} -DOCULUS=TRUE -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -G "Visual Studio 14 2015"
elif [ "${PLATFORM}" == "oculus_macOS" ]
then
  cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} -DOCULUS=TRUE -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -G "Xcode"
elif [ "${PLATFORM}" == "vr_ios" ]
then
  cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} -DVR=TRUE -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -G "Xcode" -DIOS:BOOL=TRUE
else
  cmake -E env CFLAGS='-O0 -g' cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}
fi

# cmake --build . --config Release --target install

if [ "${PLATFORM}" == "emscripten" ]
then
  emcmake cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}
  cmake --build . --config Release --target install
elif [ "${PLATFORM}" == "facebook" ]
then
  emcmake cmake .. -DEXECUTABLE_NAME:STRING=${EXECUTABLE_NAME} -DEXECUTABLE_GITHUB_REPOSITORY:STRING=${EXECUTABLE_GITHUB_REPOSITORY} -DEXECUTABLE_GITHUB_ACCOUNT:STRING=${EXECUTABLE_GITHUB_ACCOUNT} -DFACEBOOK-APP-ID="344740292600474" -DFACEBOOK-API-VERSION="v2.12" -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DFACEBOOK:BOOL=TRUE
  cmake --build . --config Release --target install
fi

cd ..
