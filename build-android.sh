#!/bin/sh
# Copyright (C) 2010 Mystic Tree Games
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Author: Moritz "Moss" Wundke (b.thax.dcg@gmail.com)
#
# <License>
#
# Build boost for android completly. It will download boost 1.45.0
# prepare the build system and finally build it for android

# Add common build methods
. `dirname $0`/build-common.sh

# Build constants
# TODO: Make boost stuff be configurable
BOOST_DOWNLOAD_LINK="http://downloads.sourceforge.net/project/boost/boost/1.45.0/boost_1_45_0.tar.bz2?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fboost%2Ffiles%2Fboost%2F1.45.0%2F&ts=1291326673&use_mirror=garr"
BOOST_TAR="boost_1_45_0.tar.bz2"
BOOST_DIR="boost_1_45_0"
BUILD_DIR="./build/"

CLEAN=no
register_option "--clean"    do_clean     "Perform a clean build deleting all previus build files."
do_clean () {	CLEAN=yes; }

DOWNLOAD=no
register_option "--download" do_download  "Only download required files and clean up previus build. No build will be performed."

do_download ()
{
	DOWNLOAD=yes
	# Clean previus stuff too!
	CLEAN=yes
}

LIBRARIES=--with-libraries=date_time,filesystem,program_options,regex,signals,system,thread,iostreams

register_option "--with-libraries=<list>" do_with_libraries "Comma separated list of libraries to build."
do_with_libraries () { LIBRARIES="--with-libraries=$1"; }

register_option "--without-libraries=<list>" do_without_libraries "Comma separated list of libraries to exclude from the build."
do_without_libraries () {	LIBRARIES="--without-libraries=$1"; }



PROGRAM_PARAMETERS="<ndk-root>"
PROGRAM_DESCRIPTION=\
"       Boost For Android\n"\
"Copyright (C) 2010 Mystic Tree Games\n"\
"------------------------------------"

extract_parameters $@

export AndroidNDKRoot=$PARAMETERS
if [ -z "$AndroidNDKRoot" ] ; then
	if [ -z "`which ndk-build`" ]; then
		dump "ERROR: You need to provide a <ndk-root>!"
		exit 1
	fi
	AndroidNDKRoot=`which ndk-build`
	AndroidNDKRoot=`dirname $AndroidNDKRoot`
	echo "Using AndroidNDKRoot = $AndroidNDKRoot"
fi

# Set deafult NDK release number
NDK_RN=4

if [ -n "`echo $AndroidNDKRoot | grep 'ndk-r5'`" ]; then
	NDK_RN=5

	if [ -n "`echo $AndroidNDKRoot | grep 'crystax'`" ]; then
		CRYSTAX_WCHAR=1
	fi
elif [ -n "`echo $AndroidNDKRoot | grep 'ndk-r7-crystax'`" ]; then
	NDK_RN=7
	CRYSTAX_WCHAR=1
elif [ -n "`echo $AndroidNDKRoot | grep 'ndk-r8'`" ]; then
	NDK_RN=8
fi



if [ $CLEAN = yes ] ; then
	echo "Cleaning: $BUILD_DIR"
	rm -f -r $PROGDIR/$BUILD_DIR
	
	echo "Cleaning: $BOOST_DIR"
	rm -f -r $PROGDIR/$BOOST_DIR
	
	echo "Cleaning: $BOOST_TAR"
	rm -f $PROGDIR/$BOOST_TAR
fi

# Check if android NDK path has been set 
if [ ! -n "${AndroidNDKRoot:+x}" ]
then
	echo "Environment variable: AndroidNDKRoot not set! Please enter tell me where you got the NDK root:"
	read AndroidNDKPatch
fi

# Check platform patch
case "$HOST_OS" in
    linux)
        Platfrom=linux-x86
        ;;
    darwin|freebsd)
        Platfrom=darwin-x86
        ;;
    windows|cygwin)
        Platfrom=windows-x86
        ;;
    *)  # let's play safe here
        Platfrom=linux-x86
esac


case "$NDK_RN" in
	4)
		CXXPATH=$AndroidNDKRoot/build/prebuilt/$Platfrom/arm-eabi-4.4.0/bin/arm-eabi-g++
		CXXFLAGS=-I$AndroidNDKRoot/build/platforms/android-8/arch-arm/usr/include
		TOOLSET=gcc-androidR4
		;;
	5)
		CXXPATH=$AndroidNDKRoot/toolchains/arm-linux-androideabi-4.4.3/prebuilt/$Platfrom/bin/arm-linux-androideabi-g++
		CXXFLAGS="-I$AndroidNDKRoot/platforms/android-8/arch-arm/usr/include \
				-I$AndroidNDKRoot/sources/cxx-stl/gnu-libstdc++/include \
				-I$AndroidNDKRoot/sources/cxx-stl/gnu-libstdc++/libs/armeabi/include \
				-I$AndroidNDKRoot/sources/wchar-support/include"
		TOOLSET=gcc-androidR5
		;;
	7)
		CXXPATH=$AndroidNDKRoot/toolchains/arm-linux-androideabi-4.6.3/prebuilt/$Platfrom/bin/arm-linux-androideabi-g++
		CXXFLAGS="-I$AndroidNDKRoot/platforms/android-9/arch-arm/usr/include \
				-I$AndroidNDKRoot/sources/cxx-stl/gnu-libstdc++/include/4.6.3 \
				-I$AndroidNDKRoot/sources/cxx-stl/gnu-libstdc++/libs/armeabi/4.6.3/include \
				-I$AndroidNDKRoot/sources/crystax/include"
		TOOLSET=gcc-androidR7
		;;
	8)
		CXXPATH=$AndroidNDKRoot/toolchains/arm-linux-androideabi-4.4.3/prebuilt/$Platfrom/bin/arm-linux-androideabi-g++
		CXXFLAGS="-I$AndroidNDKRoot/platforms/android-9/arch-arm/usr/include \
				-I$AndroidNDKRoot/sources/cxx-stl/gnu-libstdc++/include \
				-I$AndroidNDKRoot/sources/cxx-stl/gnu-libstdc++/libs/armeabi/include"
		TOOLSET=gcc-androidR8
		;;
	*)
		echo "Undefined or not supported Android NDK version!"
		exit 1
esac

echo Building with TOOLSET=$TOOLSET CXXPATH=$CXXPATH CXXFLAGS=$CXXFLAGS | tee $PROGDIR/build.log

# Check if the ndk is valid or not
if [ ! -f $CXXPATH ]
then
	echo "Cannot find C++ compiler at: $CXXPATH"
	exit 1
fi

# -----------------------
# Download required files
# -----------------------

# Downalod and unzip boost 1_45_0 in a temporal folder and
if [ ! -f $BOOST_TAR ]
then
	echo "Downloading boost 1.45.0 please wait..."
	prepare_download
	download_file $BOOST_DOWNLOAD_LINK $PROGDIR/$BOOST_TAR
fi

if [ ! -f $PROGDIR/$BOOST_TAR ]
then
	echo "Failed to download boost! Please download boost 1.45.0 manually\nand save it in this directory as $BOOST_TAR"
	exit 1
fi

if [ ! -d $PROGDIR/$BOOST_DIR ]
then
	echo "Unpack boost"
	tar xjf $PROGDIR/$BOOST_TAR
fi

if [ $DOWNLOAD = yes ] ; then
	echo "All required files has been downloaded and unpacked!"
	exit 0
fi

# ---------
# Bootstrap
# ---------
if [ ! -f ./$BOOST_DIR/bjam ]
then
	# Make the initial bootstrap
	echo "Performing boost bootstrap"

	cd $BOOST_DIR 
	./bootstrap.sh --prefix="./../$BUILD_DIR/" 			\
								 $LIBRARIES 											\
								 2>&1 | tee -a $PROGDIR/build.log

	if [ $? != 0 ] ; then
		dump "ERROR: Could not perform boostrap! See $TMPLOG for more info."
		exit 1
	fi
	cd $PROGDIR
	
	# -------------------------------------------------------------
	# Patching will be done only if we had a successfull bootstrap!
	# -------------------------------------------------------------

	# Apply patches to boost
	PATCHES_DIR=$PROGDIR/patches
	if [ -d "$PATCHES_DIR" ] ; then
		mkdir -p $PROGDIR/patches
	fi

	PATCHES=`(cd $PATCHES_DIR && find . -name "*.patch" | sort) 2> /dev/null`
	if [ -z "$PATCHES" ] ; then
		echo "No patches files in $PATCHES_DIR"
		exit 0
	fi

	PATCHES=`echo $PATCHES | sed -e s%^\./%%g`
	SRC_DIR=$PROGDIR/$BOOST_DIR
	for PATCH in $PATCHES; do
		PATCHDIR=`dirname $PATCH`
		PATCHNAME=`basename $PATCH`
		log "Applying $PATCHNAME into $SRC_DIR/$PATCHDIR"
		cd $SRC_DIR && patch -p1 < $PATCHES_DIR/$PATCH && cd $PROGDIR
		if [ $? != 0 ] ; then
			dump "ERROR: Patch failure !! Please check your patches directory! Try to perform a clean build using --clean"
			exit 1
		fi
	done
fi

# ---------------
# Build using NDK
# ---------------

# Build boost for android
echo "Building boost for android"
cd $BOOST_DIR
env PATH=`dirname $CXXPATH`:$PATH \
 AndroidNDKRoot=$AndroidNDKRoot NO_BZIP2=1 \
 ./bjam toolset=$TOOLSET -q \
 cxxflags="$CXXFLAGS" \
 link=static threading=multi --layout=versioned install 2>&1 | tee -a $PROGDIR/build.log
if [ $? != 0 ] ; then
	dump "ERROR: Failed to build boost for android!"
	exit 1
fi
cd $PROGDIR
dump "Done!"
