#!/bin/bash

KERNELNAME=Deagle
KERNELVERSION=beta
DEVICES=whyred
TOOLCHAIN=clang

export KBUILD_BUILD_USER=builder
export KBUILD_BUILD_HOST=deagle

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/tools.sh

if [ $TOOLCHAIN == "clang" ]; then
	git clone --depth=1 https://github.com/NusantaraDevs/clang.git -b dev/11.0 clang
	git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 --depth=1 gcc
	git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 --depth=1 gcc32

	START=$(date +"%s")
	sendmsg_intro $KERNELVERSION $TOOLCHAIN
	export LOCALVERSION=$KERNELVERSION

	for i in ${DEVICES//,/ }
	do
		BUILDDATE=$(date +"%y%m%d-%H%M")
		build_clang "deagle_${i}_defconfig"
        	ZIPNAME="${KERNELNAME}-${i}-${KERNELVERSION}-${BUILDDATE}.zip"
        	zipper ${i} $ZIPNAME
		sendmsg_file $ZIPNAME
		build_clean
		#build newcam blob
		build_clang "deagle_${i}_newcam_defconfig"
		ZIPNAME="${KERNELNAME}-${i}-${KERNELVERSION}-newcam-${BUILDDATE}.zip"
		zipper ${i} $ZIPNAME
		sendmsg_file $ZIPNAME
		build_clean
	done

	END=$(date +"%s")
	sendmsg_finish $START $END
else
	exit 1
fi
