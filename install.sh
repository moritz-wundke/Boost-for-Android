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
