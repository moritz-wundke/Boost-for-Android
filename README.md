# Boost for Android
Boost for android is a set of tools to compile the main part of the [Boost C++ Libraries](http://www.boost.org/) for the Android platform.

Currently supported boost versions are 1.45.0, 1.48.0, 1.49.0 and 1.53.0. Boost 1.54.0 and 1.55.0 shall be considered experimental.

To compile Boost for Android you may use one of the following NDKs:

| NDK / boost | 1.45 | 1.48 | 1.49 | 1.53 |
| ----------- | ---- | ---- | ---- | ---- |
| r4 customized by [Dmitry Moskalchuk aka CrystaX](http://www.crystax.net/android/ndk.php). | x |   |   |   |
| r5 from the [official android repository](http://developer.android.com).                  | x |   |   |   |
| r5 customized by [CrystaX](http://www.crystax.net/android/ndk.php).                       | x |   |   |   |
| r7 customized by [CrystaX](http://www.crystax.net/android/ndk.php).                       | x | x | x |   |
| r8 from the [official android repository](http://developer.android.com).                  | x | x | x |   |
| r8b from the [official android repository](http://developer.android.com).                 |   | x | x |   |
| r8c from the [official android repository](http://developer.android.com).                 |   |   | x |   |
| r8d from the [official android repository](http://developer.android.com).                 |   |   | x | x |
| r8e from the [official android repository](http://developer.android.com).                 |   |   | x | x |

# Quick Start

## Dependencies

 * NDK ([official](http://developer.android.com) or [customized by CrystaX](http://www.crystax.net/android/ndk.php))
 * GNU Make

## Usage

    $ ./build-android.sh $(NDK_ROOT)

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

### Building from a 64 bit machine (linux)

Make sure you have installed the 32 bit libraries. Those are required to be able
to use the NDK.

To install them just use the following

    $ sudo apt-get install ia32-libs

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
