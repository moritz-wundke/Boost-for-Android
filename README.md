# Boost for Android
Boost for android is a set of tools to compile the main part of the [Boost C++ Libraries](http://www.boost.org/) for the Android platform.

Currently supported boost versions are 1.45.0, 1.48.0, 1.49.0, 1.53.0, 1.54.0, 1.55.0, 1.65.1, 1.66.0, 1.67.0, 1.68.0, 1.69.0 and 1.70.0.

x86, mips, and 64-bit architectures are built with Boost 1.65.1 and NDK r16-beta2, this version uses clang toolchain with llvm libc++ STL library.

Other versions of Boost are built only for arm architecture, they are using gcc toolchain and gnustl library.

To compile Boost for Android you may use one of the following NDKs:

| NDK / boost | 1.45 | 1.48 | 1.49 | 1.53 | 1.65 | 1.66 | 1.67 | 1.68 | 1.69 | 1.70 |
| ----------- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| r4 customized by [Dmitry Moskalchuk aka CrystaX](http://www.crystax.net/android/ndk.php). | x |   |   |   |   |   |   |   |   |   |
| r5 from the [official android repository](http://developer.android.com).                  | x |   |   |   |   |   |   |   |   |   |
| r5 customized by [CrystaX](http://www.crystax.net/android/ndk.php).                       | x |   |   |   |   |   |   |   |   |   |
| r7 customized by [CrystaX](http://www.crystax.net/android/ndk.php).                       | x | x | x |   |   |   |   |   |   |   |
| r8 from the [official android repository](http://developer.android.com).                  | x | x | x |   |   |   |   |   |   |   |
| r8b from the [official android repository](http://developer.android.com).                 |   | x | x |   |   |   |   |   |   |   |
| r8c from the [official android repository](http://developer.android.com).                 |   |   | x |   |   |   |   |   |   |   |
| r8d from the [official android repository](http://developer.android.com).                 |   |   | x | x |   |   |   |   |   |   |
| r8e from the [official android repository](http://developer.android.com).                 |   |   | x | x |   |   |   |   |   |   |
| r10 from the [official android repository](http://developer.android.com).                 |   |   | x | x |   |   |   |   |   |   |
| r16 from the [official android repository](http://developer.android.com).                 |   |   |   |   | x | x | x | x |   | x |
| r17b from the [official android repository](http://developer.android.com).                |   |   |   |   |   |   | x | x |   | x |
| r18 from the [official android repository](http://developer.android.com).                 |   |   |   |   |   |   |   | x |   |   |
| r18b from the [official android repository](http://developer.android.com).                |   |   |   |   |   |   |   | x | x | x |
| r19 from the [official android repository](http://developer.android.com).                 |   |   |   |   |   |   |   |   | x |   |
| r19c from the [official android repository](http://developer.android.com).                |   |   |   |   |   |   |   |   | x | x |
| r20 from the [official android repository](http://developer.android.com).                |   |   |   |   |   |   |   |   |   | x |

For NDK from r4 to r10, GCC with gnustl_static runtime library is used, only ARM architecture is supported.

For NDK from r16 to r18b, clang with c++_static runtime library is used, all architectures are supported.

For NDK from r19 and up, clang with c++_shared runtime library is used, all architectures are supported.

# Quick Start

## Dependencies

 * NDK ([official](http://developer.android.com) or [customized by CrystaX](http://www.crystax.net/android/ndk.php))
 * GNU Make
 * autoconf, automake, libtool, pkg-config

## Usage

### Compiling

Linux.
```
./build-android.sh $(NDK_ROOT)
```
Windows:
```
build-android.bat $(NDK_ROOT)
```
NOTE: Do not forget to replace backslash with slashes in $(NDK_ROOT). For example set $(NDK_ROOT) to D:/android-ndk-r8e instead of D:\android-ndk-r8e
    
On windows you will need MSYS to be able to launch the corresponding bat files (http://www.mingw.org/wiki/MSYS).
    
This command will download and build boost against the NDK specified and output the final headers and libs in the `build` folder. Make sure to provide an absolute path the the NDK folder!

For more info about usage and available commands use `--help`.

### Including

Now that you got Boost compiled you must add it to your `Android.mk` file. Locate the `build` folder and copy the `include` and `lib` folders over to your project's `jni` folder. A recommended path inside your project is `/jni/boost/`.

Add the following to your `Android.mk` (note that here we're using Boost 1.48 and have assumed that Boost resides inside `/jni/boost`):

    LOCAL_CFLAGS += -I$(LOCAL_PATH)/boost/include/boost-1_48
    LOCAL_LDLIBS += -L$(LOCAL_PATH)/boost/lib/ -lboost_system -lboost_...

    LOCAL_CPPFLAGS += -fexceptions
    LOCAL_CPPFLAGS += -frtti

Now use `ndk-build` to build and have fun with it!

Note that you should build your project and Boost with the same version of NDK as the C++ STL inside NDK r4 and NDK r5 are not compatible in some subtle details.

## Contribute

The projects is split into two main branches, the master and devel. The master branch is where the current stable version lies and which should be used in most of the cases, the devel branch in turn is where development occurs. To contribute to the project make sure to use the devel branch which will make it easier to test changes and to merge incoming pull requests (PR).

## Troubleshooting

In case you encounter bunch of linker errors when building your app with boost, 
this might help:

### Building from a 64 bit machine (Linux)

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

### NDK 17 (official)

Support for ARMv5 (armeabi), MIPS, and MIPS64 has been removed. Attempting to build any of these ABIs will result in an error.
This project will exclude these architectures for compiling with NDK 17.

