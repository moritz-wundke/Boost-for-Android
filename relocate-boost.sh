. install-common.sh
origin=$(pwd)
findFileOrFolder gradle
if [[ -z $findFileOrFolderResult ]]
  then
    echo "top level directory could not be located"
    exit
  else
    echo "top level directory located at $findFileOrFolderResult"
    baseFolder="$(basename "$origin")"
    echo "basefolder = $baseFolder"
    boostdir="$path/$baseFolder"
    echo "boostdir = $boostdir"
    if [[ "$boostdir" == "$origin" ]]
      then
        echo script cannot be invoked from top level
        exit
    fi
    cd "$path" 2>/dev/null
    if [[ $? != 0 ]]
      then
        echo failed to cd into "$path"
        echo exiting
        exit 1
    fi
    echo relocating Boost...
    cleanFolder "$baseFolder"
    mv "$origin" "$baseFolder"
    cd "$baseFolder"
    echo relocated Boost...
fi
