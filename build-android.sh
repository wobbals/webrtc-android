#!/bin/bash -x
set -e

BASE_PATH=$(pwd)
BRANCH=trunk
gclient config https://webrtc.googlecode.com/svn/trunk
echo "target_os = ['android', 'unix']" >> .gclient
gclient sync --nohooks

cd $BRANCH
ARCHS="x86 arm"
DEST_DIR=out/android
LIBS_DEST=$DEST_DIR/libs
rm -rf $LIBS_DEST
mkdir -p $LIBS_DEST

for ARCH in $ARCHS; do
	rm -rf out/Release
	source build/android/envsetup.sh --target-arch=$ARCH

	GYP_DEFINES="build_with_libjingle=1 build_with_chromium=0 enable_android_opensl=0 enable_tracing=1 include_tests=0 $GYP_DEFINES" gclient runhooks
	ninja -C out/Release all

	AR=${BASE_PATH}/$BRANCH/`./third_party/android_tools/ndk/ndk-which ar`
	cd $LIBS_DEST
	for a in `ls $BASE_PATH/$BRANCH/out/Release/*.a` ; do 
		$AR -x $a
	done
	$AR -q libwebrtc_$ARCH.a *.o
	rm -f *.o
	cd $BASE_PATH/$BRANCH
done

cp $BASE_PATH/$BRANCH/out/Release/*.jar $LIBS_DEST

HEADERS=`find webrtc third_party talk -name *.h | grep -v android_tools`
HEADERS_DEST=$DEST_DIR/include
while read -r header; do
    mkdir -p $HEADERS_DEST/`dirname $header`
    cp $header $HEADERS_DEST/`dirname $header`
done <<< "$HEADERS"

tar cjf android-webrtc.tar.bz2 -C $DEST_DIR .

cd $BASE_PATH
REVISION=`svn info $BRANCH | grep Revision | cut -f2 -d: | tr -d ' '`
echo "WEBRTC_REVISION=$REVISION" > build.properties
