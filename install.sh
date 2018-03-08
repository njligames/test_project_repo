#!/bin/bash

PLATFORM=$1
PRE=""

cd $BUILD_DIR

if [ "${PLATFORM}" == "android" ]
then
  ./gradlew installRelease
else
  make install
fi

cd ..



