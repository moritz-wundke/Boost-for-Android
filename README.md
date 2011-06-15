# Boost for Android
Boost for android is a set of tools to compile the main part of the [Boost C++ Libraries](http://www.boost.org/) for the Android platform.

To compile Boost for Android you may use the customized NDK r4b provided by [Dmitry Moskalchuk aka CrystaX](http://www.crystax.net/android/ndk.php).
Or you may download [official NDK r5c](http://developer.android.com).

# Quick Start

## Dependencies

 * [NDK r5c](http://developer.android.com)
 * GNU Make

## Usage

./build-android.sh crystax/ndk/root

This command will download and build boost against the Crystax NDK and output the final headsr and libs and in the build folder.

For more info about usage and available commands use --help

Now that you got boost compiled you must add it to your Android.mk file. First copy the the inlcude and lib filder over to your jni folder. I copied it just into: /jni/boost/.

Add the following to your Android.mk:

    LOCAL_CFLAGS += -I$(LOCAL_PATH)/boost/include/ 
    LOCAL_LDLIBS += -L$(LOCAL_PATH)/external/boost/lib/ -lboost_system -lboost_...

    LOCAL_CPPFLAGS += -fexceptions
    LOCAL_CPPFLAGS += -frtti

Now use crystax ndk-build and have fun with it!
Also note that you should build your projct and Boost with one version of NDK -
STL inside NDK r4 and NDK r5 are not compatible in some subtle details.
