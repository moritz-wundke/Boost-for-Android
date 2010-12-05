#!/bin/sh
# Copyright (C) 2010 Mystic Tree Games
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

export AndroidNDKPatch="/home/arimoss/Android/android-ndk-r4-crystax/"

CLEAN=no
register_option "--clean"          do_clean     "Perform a clean build deleting all previus build files."

do_clean ()
{
	CLEAN=yes
}

DOWNLOAD=no
register_option "--download"       do_download  "Only download required files and clean up previus build. No build will be performed."

do_download ()
{
	DOWNLOAD=yes
	# Clean previus stuff too!
	CLEAN=yes
}

PROGRAM_DESCRIPTION=\
"       Boost For Android\n"\
"Copyright (C) 2010 Mystic Tree Games\n"\
"------------------------------------"

extract_parameters $@

if [ $CLEAN = yes ] ; then
	echo "Cleaning: $BUILD_DIR"
	rm -f -r $PROGDIR/$BUILD_DIR
	
	echo "Cleaning: $BOOST_DIR"
	rm -f -r $PROGDIR/$BOOST_DIR
	
	echo "Cleaning: $BOOST_TAR"
	rm -f $PROGDIR/$BOOST_TAR
fi

# Check if android NDK path has been set 
if [ ! -n "${AndroidNDKPatch:+x}" ]
then
	echo "Environment variable: AndroidNDKPatch not set! Please enter tell me where you got the NDK root:"
	read AndroidNDKPatch
fi

# Check if the ndk is valid or not
if [ ! -f $AndroidNDKPatch/build/prebuilt/linux-x86/arm-eabi-4.4.0/bin/arm-eabi-c++ ]
then
	echo "Invalid path. Aborting"
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
	tar xvjf $PROGDIR/$BOOST_TAR
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
	echo "Performing boost boostrap"

	cd $BOOST_DIR 
	run ./bootstrap.sh	
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
run ./bjam link=static threading=multi --layout=versioned install
if [ $? != 0 ] ; then
	dump "ERROR: Failed to build boost for android!"
	exit 1
fi
cd $PROGDIR
dump "Done!"
