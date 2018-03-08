#!/bin/bash

PLATFORM=$1
PRE=""

cd $BUILD_DIR

if [ "${PLATFORM}" == "android" ]
then
  ./gradlew clean
else
  make clean
fi

cd ..



