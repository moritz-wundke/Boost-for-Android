echo_() {
    echo -ne "$@\033[0K\r"
#     echo "$@"
}

requireArguments() {
    ret=0
    invocation="requireArguments $@"
    if [[ $# < 2 ]]
        then
            if [[ $# == 0 ]]
                then
                    echo "error: the function 'requireArguments' must be called with at least 2 arguments, but no arguments where supplied"
            elif [[ $# == 1 ]]
                then
                    echo "error: the function 'requireArguments' must be called with at least 2 arguments, but only the argument count was supplied"
            fi
            exit 1
    fi
    argumentCount=$1
    shift 1
    actualArgumentCount=$#
    argumentsRecieved=$@
    if [[ $argumentCount != $actualArgumentCount ]]
        then
            ret=1
            echo "invocation: $invocation"
            echo "required argument count: $argumentCount"
            echo "actual argument count: $actualArgumentCount"
            echo "arguments recieved: $argumentsRecieved"
    fi
    return $ret
}

startsWith() {
    if requireArguments 2 $@
        then
            if [[ "$1" == "$2"* ]]
                then
                    return 0
            fi
    fi
    return 1
}

parentDirectory() {
    if requireArguments 1 $@
        then
            path=$1
            if [[ "$path" != "" ]]
                then
                    path=${path%/*}
            fi
            if [[ "$path" != "" ]]
                then
                    path=${path%/*}
            fi
    fi
    export parentDirectoryResult="$path"
    if [[ "$path" == "" ]]
        then
            return 1
        else
            return 0
    fi
}

removePrefix() {
    if requireArguments 2 $@
        then
            removePrefixResult="${2#$1}"
    fi
}

showFileNames=1 # false

recursiveCopyDepth=0
recursiveCopy() {
    if requireArguments 2 $@
        then
            local origin="$(pwd)"
            if startsWith "$1" /
                then
                    local p="$1"
                else
                    local p="$origin/$1"
            fi
            
            if startsWith "$2" /
                then
                    local p2="$2"
                else
                    local p2="$origin/$2"
            fi

            if [[ $recursiveCopyDepth == 0 ]]
                then
                    parentDirectory "$p"
                    removePrefix "$p" "$parentDirectoryResult/"
                    recursiveCopyORIGIN="$removePrefixResult"
                    removePrefix "$parentDirectoryResult/" "$p"
                    recursiveCopyORIGIN_="$removePrefixResult"
                    
                    parentDirectory "$p2"
                    removePrefix "$p2" "$parentDirectoryResult/"
                    recursiveCopyDEST="$removePrefixResult"
                    removePrefix "$parentDirectoryResult/" "$p2"
                    recursiveCopyDEST_="$removePrefixResult"

                    echo origin ".../$recursiveCopyORIGIN_"
                    echo dest ".../$recursiveCopyDEST_"
                    removePrefix $recursiveCopyDEST $p2
                    local pp2=".../$removePrefixResult"
                    if [[ $recursiveCopyDepth > 2 ]]
                        then
                            removePrefix ${p2%/*} $p2
                            local pp2=".../$recursiveCopyDEST_/...$removePrefixResult"
                    fi
                    echo_ "creating directory $pp2"
                    mkdir "$p2"
            fi
            recursiveCopyDepth=$(($recursiveCopyDepth+1))

            local files=$(ls -a "$p" | grep -v "^.$" | grep -v "^..$" | xargs)
            for f in $files
                do
                    local x="$p/$f"
                    local x2="$p2/$f"
                    if [[ -d "$x" ]]
                        then
                            removePrefix $recursiveCopyORIGIN $x
                            local xx=".../$removePrefixResult"
                            removePrefix $recursiveCopyDEST $x2
                            local xx2=".../$removePrefixResult"
                            if [[ $recursiveCopyDepth > 1 ]]
                                then
                                    removePrefix ${x%/*} $x
                                    local xx=".../$recursiveCopyORIGIN_/...$removePrefixResult"
                                    removePrefix ${x2%/*} $x2
                                    local xx2=".../$recursiveCopyDEST_/...$removePrefixResult"
                            fi
                            echo_ "entering directory $xx"
                            cd "$x"
                            if startsWith "$x2" /
                                then
                                    local _p2="$x2"
                                else
                                    local _p2="$origin/$x2"
                            fi

                            removePrefix $recursiveCopyDEST $_p2
                            local _pp2=".../$removePrefixResult"
                            if [[ $recursiveCopyDepth > 1 ]]
                                then
                                    removePrefix ${_p2%/*} $_p2
                                    local _pp2=".../$recursiveCopyDEST_/...$removePrefixResult"
                            fi
                            echo_ "creating directory $_pp2"
                            mkdir "$_p2"
                            echo_ "coping $xx to $xx2"
                            recursiveCopy "$x" "$x2"
                            echo_ "leaving directory $xx"
                            cd "$p"
                    fi
            done
            for f in $files
                do
                    local x="$p/$f"
                    local x2="$p2/$f"
                    if [[ -f "$x" ]]
                        then
                            if [[ $showFileNames == 0 ]]
                                then
                                    removePrefix $recursiveCopyORIGIN $x
                                    local xx=".../$removePrefixResult"
                                    removePrefix $recursiveCopyDEST $x2
                                    local xx2=".../$removePrefixResult"
                                    if [[ $recursiveCopyDepth > 1 ]]
                                        then
                                            removePrefix ${x%/*} $x
                                            local xx=".../$recursiveCopyORIGIN_/...$removePrefixResult"
                                            removePrefix ${x2%/*} $x2
                                            local xx2=".../$recursiveCopyDEST_/...$removePrefixResult"
                                    fi
                                    echo_ "coping $xx to $xx2"
                            fi
                            cp "$x" "$x2"
                    fi
            done
            recursiveCopyDepth=$(($recursiveCopyDepth-1))
            if [[ $recursiveCopyDepth == 0 ]]
                then
                    echo_ "leaving directory $1"
                    cd "$origin"
                    echo_ "copied $1"
                    echo
            fi
    fi
}

recursiveRemoveDepth=0
recursiveRemove() {
    if requireArguments 1 $@
        then
            local origin="$(pwd)"
            if startsWith "$1" /
                then
                    local p="$1"
                else
                    local p="$origin/$1"
            fi

            if [[ $recursiveRemoveDepth == 0 ]]
                then
                    parentDirectory "$p"
                    removePrefix "$p" "$parentDirectoryResult/"
                    recursiveRemoveORIGIN="$removePrefixResult"
                    removePrefix "$parentDirectoryResult/" "$p"
                    recursiveRemoveORIGIN_="$removePrefixResult"
            fi
            recursiveRemoveDepth=$(($recursiveRemoveDepth+1))
            local files=$(ls -a "$p" | grep -v "^.$" | grep -v "^..$" | xargs)
            for f in $files
                do
                    local x="$p/$f"
                    if [[ -d "$x" ]]
                        then
                            local xx="$x"
                            removePrefix $recursiveRemoveORIGIN $x
                            local xx=".../$removePrefixResult"
                            if [[ $recursiveRemoveDepth > 1 ]]
                                then
                                    removePrefix ${x%/*} $x
                                    local xx=".../$recursiveRemoveORIGIN_/...$removePrefixResult"
                            fi
                            echo_ "entering directory $xx"
                            cd "$x"
                            echo_ "removing directory $xx"
                            recursiveRemove "$x"
                            rmdir "$x"
                            echo_ "leaving directory $xx"
                            cd "$p"
                    fi
            done
            for f in $files
                do
                    local x="$p/$f"
                    if [[ -f "$x" ]]
                        then
                            if [[ $showFileNames == 0 ]]
                                then
                                    local xx="$x"
                                    removePrefix $recursiveRemoveORIGIN $x
                                    local xx=".../$removePrefixResult"
                                    if [[ $recursiveRemoveDepth > 1 ]]
                                        then
                                            removePrefix ${x%/*} $x
                                            local xx=".../$recursiveRemoveORIGIN_/...$removePrefixResult"
                                    fi
                                    echo_ "removing $xx"
                            fi
                            rm "$x"
                    fi
            done
            recursiveRemoveDepth=$(($recursiveRemoveDepth-1))
            if [[ $recursiveRemoveDepth == 0 ]]
                then
                    echo_ "leaving directory $1"
                    cd "$origin"
                    echo_ "removed $1"
                    rmdir "$1"
                    echo
            fi
    fi
}

cleanFolder () {
    if requireArguments 1 $@
        then
            if [[ -e "$1" ]]
                then
                    echo "cleaning $1 folder..."
                    rm -rf "$1"
                    echo "cleaned $1 folder"
            fi
    fi
}

findFileOrFolder() {
    if requireArguments 1 $@
        then
            path=$(pwd)
            while [[ "$path" != "" && ! -e "$path/$1" ]]
                do
                    path=${path%/*}
            done
    fi
    export findFileOrFolderResult="$path"
    if [[ "$path" == "" ]]
        then
            return 1
        else
            return 0
    fi
}
