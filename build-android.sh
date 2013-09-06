#!/bin/sh -xe
export PATH=$PATH:`pwd`/depot_tools

BRANCH=trunk
gclient sync --nohooks

cd $BRANCH
. ./build/android/envsetup.sh
gclient runhooks
#ninja -C out/Debug -t targets
ninja -C out/Debug WebRTCDemo

LIBS=`find out/Debug -name '*.a' -maxdepth 3`

LIBS_DEST=out/android/libs
mkdir -p $LIBS_DEST
while read -r lib; do
    cp $lib $LIBS_DEST
done <<< "$LIBS"

HEADERS=`find webrtc third_party -name *.h | grep -v android_tools`
HEADERS_DEST=out/android/include
while read -r header; do
    mkdir -p $HEADERS_DEST/`dirname $header`
    cp $header $HEADERS_DEST/`dirname $header`
done <<< "$HEADERS"

tar cjf android-webrtc.tar.bz2 out/android
