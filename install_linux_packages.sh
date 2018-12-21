#!/bin/bash

sudo apt-get update
sudo apt-get upgrade

# sudo apt-get install libglu1-mesa-dev freeglut3-dev mesa-common-dev
# sudo apt-get -y install swig
# sudo apt-get -y install doxygen
# http://embedonix.com/articles/linux/installing-cmake-3-5-2-on-ubuntu/

sudo apt-get install \
	libopenal-dev \
	build-essential \
	libsdl2-dev \
	doxygen \
	graphviz \
	swig \
	vim \
	libssl-dev

# libopenal-dev

cver=3.11.0
wd=/tmp
wget -nc -P $wd https://cmake.org/files/v${cver:0:4}/cmake-$cver.tar.gz
cd $wd
tar -xf cmake-$cver.tar.gz
cd cmake-$cver
./configure
make -j8
sudo make install
cd ..
rm -rf cmake-$cver

