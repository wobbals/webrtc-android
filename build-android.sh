#!/bin/sh
gclient config https://webrtc.googlecode.com/svn/trunk
echo "target_os = ['android', 'unix']" >> .gclient
gclient sync --nohooks

cd trunk
. ./build/android/envsetup_functions.sh
. ./build/android/envsetup.sh
gclient runhooks
ninja -C out/Debug -t targets
ninja -C out/Debug video_demo_apk
