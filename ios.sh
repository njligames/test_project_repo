#!/bin/bash

./run_cmake_and_build.sh ios $1

# Run app in simulator...
# https://medium.com/xcblog/simctl-control-ios-simulators-from-command-line-78b9006a20dc


# reference to build, archive upload api...
# https://medium.com/xcblog/xcodebuild-deploy-ios-app-from-command-line-c6defff0d8b8

# Build app
# xcodebuild -project buildbot_ios/NJLIC.xcodeproj/ -scheme NJLIC-exe -destination generic/platform=iOS build

# Build archive
# xcodebuild -project buildbot_ios/NJLIC.xcodeproj/ -scheme NJLIC-exe -sdk iphoneos -configuration AppStoreDistribution archive -archivePath $PWD/build/NJLIC-exe.xcarchive

# Export ipa
# xcodebuild -exportArchive -archivePath $PWD/build/NJLIC-exe.xcarchive -exportOptionsPlist buildbot_ios/exportOptions.plist -exportPath $PWD/build

# next is to upload ipa...
# altool --upload-app -f "NJLIC-exe.ipa" -u $USERNAME -p $PASSWORD
