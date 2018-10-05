#!/bin/bash

# git submodule update --init --recursive
# git submodule foreach --recursive git fetch
# git submodule foreach git checkout origin master

git submodule update --init --recursive
git submodule foreach git checkout master
git submodule foreach git pull

dirs=(buildbot_android/ buildbot_linux/ buildbot_windows32/ buildbot_appletv/ buildbot_macOS/ buildbot_windows64/ buildbot_emscripten/ buildbot_vr_android/ buildbot_ios/ buildbot_vr_ios/)

for i in "${dirs[@]}"
do
	cd $i
	git submodule update --init --recursive
	git submodule foreach git checkout master
  git submodule foreach git pull
	cd ..
done

