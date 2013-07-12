#!/bin/sh -xe
export PATH=$PATH:`pwd`/depot_tools

BRANCH=trunk
gclient sync --nohooks

cd $BRANCH
. ./build/android/envsetup.sh
gclient runhooks
#ninja -C out/Debug -t targets
ninja -C out/Debug video_demo_apk
