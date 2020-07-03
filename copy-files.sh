. install-common.sh
if requireArguments 1 $@
    then
        origin=$(pwd)
        findFileOrFolder gradle
        if [[ -z $findFileOrFolderResult ]]
        then
            echo "top level directory could not be located"
            exit
        else
            echo "top level directory located at $findFileOrFolderResult"
            boostdir="$1"
            echo "boostdir = $boostdir"
            if [[ -e "$boostdir" ]]
            then
                mkdir -p build/out

                hasInclude=1

                for arch in $(ls "$boostdir/build/out" | xargs)
                do
                    if [[ $hasInclude == 1 ]]
                    then
                        cleanFolder "$origin/build/out/include"
                        echo "copying directory: include"
                        recursiveCopy "$boostdir/build/out/$arch/include" "$origin/build/out/include"
                        hasInclude=0
                    fi
                    if [[ ! -e "$origin/build/out/$arch/lib" ]]
                    then
                        echo "creating directory: $arch/lib"
                        mkdir -p "$origin/build/out/$arch/lib"
                    fi
                    echo "copying build/out/$arch/lib/*.a"
                    cd "$boostdir/build/out/$arch/lib"
                    for lib in $(find "." -maxdepth 1 -name "*.a" | xargs)
                    do
                        lib_basename="$(basename "$lib")"
                        echo "copying .../$lib_basename"
                        cp -P "$lib" "$origin/build/out/$arch/lib/$lib_basename"
                        echo ".../$lib_basename -> .../$arch/lib/$lib_basename"
                    done
                done
            fi
        fi
fi
