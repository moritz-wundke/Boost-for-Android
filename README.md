# Boost for Android
Boost for android is a set of tools to compile the main part of the [Boost C++ Libraries](http://www.boost.org/) for the Android platform.

To compile be able to compile Boost for Android you must use the customized NDK provided by [Dmitry Moskalchuk aka CrystaX](http://www.crystax.net/android/ndk.php) 

The port and it's toolset is still in alpha but will be improoved

# Quick Start

## Dependencies

 * [Crysrax NDK](http://www.crystax.net/android/ndk.php)
 * GNU Make

## Usage

./build-android.sh <crystax/ndk/root>

This command will download and build boost against the Crystax NDK and output the final headsr and libs and in the build folder.

For more info about usage and available commands use --help
