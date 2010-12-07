# Boost for Android
Boost for android is a set of tools to compile the main part of the [Boost C++ Libraries](http://www.boost.org/) for the Android platform.

To compile Boost for Android you must use the customized NDK provided by [Dmitry Moskalchuk aka CrystaX](http://www.crystax.net/android/ndk.php) 

The port and it's toolset iare still in alpha but will be improoved

# Quick Start

## Dependencies

 * [Crysrax NDK](http://www.crystax.net/android/ndk.php)
 * GNU Make

## Usage

./build-android.sh crystax/ndk/root

This command will download and build boost against the Crystax NDK and output the final headsr and libs and in the build folder.

For more info about usage and available commands use --help

Now that you got boost compiled you must add it to your Android.mk file. First copy the the inlcude and lib filder over to your jni folder. I copied it just into: /jni/boost/.

Add the following to your Android.mk:

    LOCAL_CFLAGS += -DMYSTIC -I$(LOCAL_PATH)/boost/include/ 
    LOCAL_LDLIBS += -L$(LOCAL_PATH)/external/boost/lib/
    
    LOCAL_CPPFLAGS += -fexceptions
    LOCAL_CPPFLAGS += -frtti
    LOCAL_CPPFLAGS +=-DBOOST_THREAD_LINUX
    LOCAL_CPPFLAGS +=-DBOOST_HAS_PTHREADS
    LOCAL_CPPFLAGS +=-D__arm__
    LOCAL_CPPFLAGS +=-D_REENTRANT
    LOCAL_CPPFLAGS +=-D_GLIBCXX__PTHREADS
    LOCAL_CPPFLAGS +=-DBOOST_HAS_GETTIMEOFDAY

Now use crystax ndk-build and have fun with it!
