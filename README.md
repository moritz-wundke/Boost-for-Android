# Boost for Android
Boost for android is a set of tools to compile the main part of the [Boost C++ Libraries](http://www.boost.org/) for the Android platform.

Currently supported boost versions are 1.45.0, 1.48.0 and 1.49.0.

To compile Boost for Android you may use one of the following NDKs:

For boost 1.45.0
- NDK r4 customized by [Dmitry Moskalchuk aka CrystaX](http://www.crystax.net/android/ndk.php).
- NDK r5 from the [official android repository](http://developer.android.com).
- NDK r5 customized by [CrystaX](http://www.crystax.net/android/ndk.php).
- NDK r7 from the [official android repository](http://developer.android.com).
- NDK r7 customized by [CrystaX](http://www.crystax.net/android/ndk.php).
- NDK r8 from the [official android repository](http://developer.android.com).

For boost 1.48.0 & 1.49.0
- NDK r7 from the [official android repository](http://developer.android.com).
- NDK r7 customized by [CrystaX](http://www.crystax.net/android/ndk.php).
- NDK r8 from the [official android repository](http://developer.android.com).

For boost 1.49.0
- NDK r8, r8c and r8d from the [official android repository](http://developer.android.com).

# Quick Start

## Dependencies

 * NDK ([official](http://developer.android.com) or [customized by CrystaX](http://www.crystax.net/android/ndk.php))
 * GNU Make

## Usage

    ./build-android.sh $(NDK_ROOT)

This command will download and build boost against the NDK specified and output the final headers and libs and in the build folder.

For more info about usage and available commands use --help

Now that you got boost compiled you must add it to your Android.mk file. First copy the inlcude and lib filder over to your jni folder. I copied it just into: /jni/boost/.

Add the following to your Android.mk (example for boost 1.48):

    LOCAL_CFLAGS += -I$(LOCAL_PATH)/boost/include/boost-1_48
    LOCAL_LDLIBS += -L$(LOCAL_PATH)/boost/lib/ -lboost_system -lboost_...

    LOCAL_CPPFLAGS += -fexceptions
    LOCAL_CPPFLAGS += -frtti

Now use ndk-build and have fun with it!
Also note that you should build your project and Boost with one version of NDK -
STL inside NDK r4 and NDK r5 are not compatible in some subtle details.


## Troubleshooting

In case you encounter bunch of linker errors when building your app with boost, 
this might help:

### NDK 7 (CrystaX)

Add `-lgnustl_static` *AFTER* all boost libraries to the LOCAL_LDLIBS line in 
Android.mk. Example:

    LOCAL_LDLIBS += lboost_system-gcc-md lboost_thread-gcc-md -lgnustl_static

### NDK 8 (official)

Do everything that is in the NDK 7 Crystax section, but also
add full path to the gnustl_static library to the link paths. Example:

    LOCAL_LDLIBS += lboost_system-gcc-md lboost_thread-gcc-md \
                 -L$(NDK_ROOT)/sources/cxx-stl/gnu-libstdc++/libs/armeabi \
                 -lgnustl_static
