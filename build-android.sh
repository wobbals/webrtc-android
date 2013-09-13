#!/bin/sh -x
set -e

BASE_PATH=$(pwd)
BRANCH=trunk
gclient config https://webrtc.googlecode.com/svn/trunk
echo "target_os = ['android', 'unix']" >> .gclient
gclient sync --nohooks

cd $BRANCH
ARCHS="x86 arm"
LIBS_DEST=out/android/libs

mkdir -p $LIBS_DEST

for ARCH in $ARCHS; do
	rm -rf out/Release
	. ./build/android/envsetup.sh  --target-arch=$ARCH

	GYP_DEFINES="build_with_libjingle=1 build_with_chromium=0 libjingle_java=1 $GYP_DEFINES" gclient runhooks
	ninja -C out/Release -t clean
	ninja -j 20 -C out/Release all

	AR=${BASE_PATH}/$BRANCH/`./third_party/android_tools/ndk/ndk-which ar`
	cd $LIBS_DEST
	for a in `ls $BASE_PATH/$BRANCH/out/Release/*.a` ; do 
		$AR -x $a
	done
	$AR -q libwebrtc_$ARCH.a *.o
	rm -f *.o
	cd $BASE_PATH/$BRANCH
done

HEADERS=`find webrtc third_party -name *.h | grep -v android_tools`
HEADERS_DEST=out/android/include
while read -r header; do
    mkdir -p $HEADERS_DEST/`dirname $header`
    cp $header $HEADERS_DEST/`dirname $header`
done <<< "$HEADERS"

tar cjf android-webrtc.tar.bz2 out/android

cd $BASE_PATH
REVISION=`svn info $BRANCH | grep Revision | cut -f2 -d: | tr -d ' '`
echo "WEBRTC_REVISION=$REVISION" > build.properties
