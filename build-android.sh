#!/bin/sh -xe
export PATH=$PATH:`pwd`/depot_tools

gclient config https://webrtc.googlecode.com/svn/trunk
echo "target_os = ['android', 'unix']" >> .gclient
gclient sync --nohooks

cd trunk/build/android
. `pwd`/envsetup.sh
cd ../..
gclient runhooks
#ninja -C out/Debug -t targets
ninja -C out/Debug video_demo_apk
