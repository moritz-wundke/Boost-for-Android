# Boost for Android [![Build Status: GitHub Actions](https://github.com/moritz-wundke/Boost-for-Android/workflows/CI/badge.svg)](https://github.com/moritz-wundke/Boost-for-Android/actions)
Boost for android is a set of tools to compile the main part of the [Boost C++ Libraries](http://www.boost.org/) for the Android platform.

Currently supported boost versions are 1.45.0, 1.48.0, 1.49.0, 1.53.0, 1.54.0, 1.55.0, 1.65.1, 1.66.0, 1.67.0, 1.68.0, 1.69.0 and 1.70.0.

x86, mips, and 64-bit architectures are built with Boost 1.65.1 and NDK r16-beta2, this version uses clang toolchain with llvm libc++ STL library.

Other versions of Boost are built only for arm architecture, they are using gcc toolchain and gnustl library.

To compile Boost for Android you may use one of the following NDKs:

| NDK / boost | 1.45 | 1.48 | 1.49 | 1.53 | 1.65 | 1.66 | 1.67 | 1.68 | 1.69 | 1.70 | 1.73 |
| ----------- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| r4 customized by [Dmitry Moskalchuk aka CrystaX](http://www.crystax.net/android/ndk.php). | x |   |   |   |   |   |   |   |   |   |   |
| r5 from the [official android repository](http://developer.android.com).                  | x |   |   |   |   |   |   |   |   |   |   |
| r5 customized by [CrystaX](http://www.crystax.net/android/ndk.php).                       | x |   |   |   |   |   |   |   |   |   |   |
| r7 customized by [CrystaX](http://www.crystax.net/android/ndk.php).                       | x | x | x |   |   |   |   |   |   |   |   |
| r8 from the [official android repository](http://developer.android.com).                  | x | x | x |   |   |   |   |   |   |   |   |
| r8b from the [official android repository](http://developer.android.com).                 |   | x | x |   |   |   |   |   |   |   |   |
| r8c from the [official android repository](http://developer.android.com).                 |   |   | x |   |   |   |   |   |   |   |   |
| r8d from the [official android repository](http://developer.android.com).                 |   |   | x | x |   |   |   |   |   |   |   |
| r8e from the [official android repository](http://developer.android.com).                 |   |   | x | x |   |   |   |   |   |   |   |
| r10 from the [official android repository](http://developer.android.com).                 |   |   | x | x |   |   |   |   |   |   |   |
| r16 from the [official android repository](http://developer.android.com).                 |   |   |   |   | x | x | x | x |   | x |   |
| r17b from the [official android repository](http://developer.android.com).                |   |   |   |   |   |   | x | x |   | x |   |
| r18 from the [official android repository](http://developer.android.com).                 |   |   |   |   |   |   |   | x |   |   |   |
| r18b from the [official android repository](http://developer.android.com).                |   |   |   |   |   |   |   | x | x | x |   |
| r19 from the [official android repository](http://developer.android.com).                 |   |   |   |   |   |   |   |   | x |   |   |
| r19c from the [official android repository](http://developer.android.com).                |   |   |   |   |   |   |   |   | x | x |   |
| r20 from the [official android repository](http://developer.android.com).                |   |   |   |   |   |   |   |   |   | x | x |

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

#### ndk-build

Now that you got Boost compiled you must add it to your `Android.mk` file. Locate the `build` folder and copy the `include` and `lib` folders over to your project's `jni` folder. A recommended path inside your project is `/jni/boost/`.

Add the following to your `Android.mk` (note that here we're using Boost 1.48 and have assumed that Boost resides inside `/jni/boost`):

    LOCAL_CFLAGS += -I$(LOCAL_PATH)/boost/include/boost-1_48
    LOCAL_LDLIBS += -L$(LOCAL_PATH)/boost/lib/ -lboost_system -lboost_...

    LOCAL_CPPFLAGS += -fexceptions
    LOCAL_CPPFLAGS += -frtti

Now use `ndk-build` to build and have fun with it!

Note that you should build your project and Boost with the same version of NDK as the C++ STL inside NDK r4 and NDK r5 are not compatible in some subtle details.

#### CMake

Now that you got Boost compiled you must add it to your `CMakeLists.txt` file.

##### Linux

run the included `install.sh` script to relocate Boost to the root project, and copy the Boost `include` and `lib` folder into a generated folder residing in the same directory

Boost must be relocated to the root project in order to `avoid` Android Studio eating all your RAM due to scanning the huge `include` folder located in each architecture build output folder

`install.sh` is comprised of a small set of helper scripts, and is basically just this:
```BASH
# import common functions
. install-common.sh

# relocate to root project
. relocate-boost.sh

# clean this folder if it exists
# note that this folder should NOT exist
# but it is better to be safe than sorry
# NOTE: this function checks if its argument
# NOTE: exists in the filesystem as any
# NOTE: type of file or folder before cleaning
cleanFolder "$origin"

# create this folder
mkdir "$origin"

# change directory to this folder
cd "$origin"

# copy helper files from relocated folder into this folder
cp -v "$boostdir/boost-dummy.cpp" "$boostdir/CMakeLists.txt" "$boostdir/copy-files.sh" "$boostdir/install-common.sh" .

# copy include and lib folders from relocated folder into this folder
./copy-files.sh "$boostdir"
```

the `install.sh` script will relocate the parent folder into the root project directory, this is to avoid gradle indexing the folder, as well as causing numurous build issues that arise from arbitary files that may be present such as example java programs (in which Boost `DOES NOT` contain)

next `install.sh` will recreate the parent folder, since it no longer exists at the expected location

next, `install.sh` copies helper scripts, the `CMakeLists.txt` cmake file, and a `boost-dummy.cpp` source file, which is used to build a single Boost library from the multiple Boost libraries

finally, `install.sh` copies the `include` folder, and `lib` folders, of the all build architecture residing in the `build` folder, only the `first include` folder is actually copied, since i believe that it is safe to assume the `include` folders do not contain architecture specific code

as an example, we shall assume we have built Boost for the architectures `arm64-v8a` and `armeabi-v7a`

filesystem structure before invoking `install.sh`:
```
RootProject/app/src/main/jni/Boost-For-Android/build/out/arm64-v8a/include
RootProject/app/src/main/jni/Boost-For-Android/build/out/arm64-v8a/lib
RootProject/app/src/main/jni/Boost-For-Android/build/out/armeabi-v7a/include
RootProject/app/src/main/jni/Boost-For-Android/build/out/armeabi-v7a/lib
RootProject/gradlew
...
```
filesystem structure after `install.sh`:
```
RootProject/Boost-For-Android/build/out/arm64-v8a/include
RootProject/Boost-For-Android/build/out/arm64-v8a/lib
RootProject/Boost-For-Android/build/out/armeabi-v7a/include
RootProject/Boost-For-Android/build/out/armeabi-v7a/lib
RootProject/app/src/main/jni/Boost-For-Android/build/out/include
RootProject/app/src/main/jni/Boost-For-Android/build/out/arm64-v8a/lib
RootProject/app/src/main/jni/Boost-For-Android/build/out/armeabi-v7a/lib
RootProject/gradlew
...
```

and as an additional example of what this actually looks like in action, with the library list ommited as it is long:
```
smallville7123@smallville7123-MacBookPro:/media/smallville7123/Untitled/USB/git/AndroidCompositor/app/src/main/jni/Boost-for-Android$ ./install.sh
top level directory located at /media/smallville7123/Untitled/USB/git/AndroidCompositor
basefolder = Boost-for-Android
boostdir = /media/smallville7123/Untitled/USB/git/AndroidCompositor/Boost-for-Android
relocating Boost...
relocated Boost...
'/media/smallville7123/Untitled/USB/git/AndroidCompositor/Boost-for-Android/boost-dummy.cpp' -> './boost-dummy.cpp'
'/media/smallville7123/Untitled/USB/git/AndroidCompositor/Boost-for-Android/CMakeLists.txt' -> './CMakeLists.txt'
'/media/smallville7123/Untitled/USB/git/AndroidCompositor/Boost-for-Android/copy-files.sh' -> './copy-files.sh'
'/media/smallville7123/Untitled/USB/git/AndroidCompositor/Boost-for-Android/install-common.sh' -> './install-common.sh'
top level directory located at /media/smallville7123/Untitled/USB/git/AndroidCompositor
boostdir = /media/smallville7123/Untitled/USB/git/AndroidCompositor/Boost-for-Android
copying directory: include
origin .../arm64-v8a/include
dest .../out/include
copied /media/smallville7123/Untitled/USB/git/AndroidCompositor/Boost-for-Android/build/out/arm64-v8a/include
creating directory: arm64-v8a/lib
copying build/out/arm64-v8a/lib/*.a
copying .../libboost_prg_exec_monitor-clang-mt-a64-1_73.a
.../libboost_prg_exec_monitor-clang-mt-a64-1_73.a -> .../arm64-v8a/lib/libboost_prg_exec_monitor-clang-mt-a64-1_73.a
...
creating directory: armeabi-v7a/lib
copying build/out/armeabi-v7a/lib/*.a
copying .../libboost_prg_exec_monitor-clang-mt-a32-1_73.a
.../libboost_prg_exec_monitor-clang-mt-a32-1_73.a -> .../armeabi-v7a/lib/libboost_prg_exec_monitor-clang-mt-a32-1_73.a
...
creating directory: x86/lib
copying build/out/x86/lib/*.a
copying .../libboost_prg_exec_monitor-clang-mt-x32-1_73.a
.../libboost_prg_exec_monitor-clang-mt-x32-1_73.a -> .../x86/lib/libboost_prg_exec_monitor-clang-mt-x32-1_73.a
...
creating directory: x86_64/lib
copying build/out/x86_64/lib/*.a
copying .../libboost_prg_exec_monitor-clang-mt-x64-1_73.a
.../libboost_prg_exec_monitor-clang-mt-x64-1_73.a -> .../x86_64/lib/libboost_prg_exec_monitor-clang-mt-x64-1_73.a
...
smallville7123@smallville7123-MacBookPro:/media/smallville7123/Untitled/USB/git/AndroidCompositor/app/src/main/jni/Boost-for-Android$
```

now that the `install.sh` script has been run, all you need to do is add this to your cmake file

##### Windows

no install script is provided

##### what to add to your cmake file

```CMAKE
# this exports two variables, BOOST_INCLUDE, and BOOST_LIBRARY
add_subdirectory(Boost-for-Android)
include_directories(${BOOST_INCLUDE})

# link with BOOST
target_link_libraries(YOUR_LIBRARY YOUR_LIBS ${BOOST_LIBRARY})
```

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

