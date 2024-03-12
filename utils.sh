#!/usr/local/bin/bash
set -eu

cap_first_letter() {
  local input="$1"
  local first_letter="$(echo "${input:0:1}" | tr '[:lower:]' '[:upper:]')"
  local rest_of_string="${input:1}"
  echo "${first_letter}${rest_of_string}"
}

cap_lower() {
  echo "$(echo "$1" | tr '[:lower:]' '[:upper:]')"
}

find_include_dir(){
    local dir=$SCRATCH/$ARCH/include/$header_dir
    if [ ! -d "$dir" ]; then
        dir=$SCRATCH/x86_64/include/$header_dir
    fi
    if [ ! -d "$dir" ]; then
        dir=$SCRATCH/arm64/include/$header_dir
    fi
    if [ ! -d "$dir" ]; then
        dir=$SCRATCH/arm64e/include/$header_dir
    fi
    echo $dir
}

declare -A XCFRAMEWORK_OPTIONS
declare -A LIPO_ARGUMENTS

create_lipo_arguments()
{
    if [ ! -v LIPO_ARGUMENTS[$1] ]; then
        LIPO_ARGUMENTS[$1]=""
    fi
    local lib_name=$1
    if [ -v 2 ]; then
        lib_name=$2
    fi
    LIPO_ARGUMENTS[$1]="${LIPO_ARGUMENTS[$1]} $(readlink -f $SCRATCH/$ARCH)/lib/$lib_name.a"
}

create_lipo()
{
    local LIPO_OUT_DIR=$SCRATCH/$(cap_first_letter $1).framework
    rm -rf  $LIPO_OUT_DIR
    mkdir -p $LIPO_OUT_DIR

    local args=("$@")

    if [ ! -v 2 ]; then
        args[1]=$LIBRARY
    fi

    for header_dir in "${args[@]:1}"; do
        mkdir -p $LIPO_OUT_DIR/Headers    
        cp -r $(find_include_dir) $LIPO_OUT_DIR/Headers
    done

    lipo -create  ${LIPO_ARGUMENTS[$1]} -output $LIPO_OUT_DIR/$(cap_first_letter $1)

    cp -a $ROOT_DIR/meta/Info.plist $LIPO_OUT_DIR/Info.plist
    sed -i "s/{NAME}/$(cap_first_letter $1)/g" $LIPO_OUT_DIR/Info.plist

    mkdir -p $LIPO_OUT_DIR/Modules
    cp -a $ROOT_DIR/meta/module.modulemap $LIPO_OUT_DIR/Modules/module.modulemap
    sed -i "s/{LIB}/$(cap_first_letter $1)/g" $LIPO_OUT_DIR/Modules/module.modulemap

    LIPO_ARGUMENTS[$1]=""
}

create_xcframework_options()
{
    if [ ! -v XCFRAMEWORK_OPTIONS[$1] ]; then
        XCFRAMEWORK_OPTIONS[$1]=""
    fi
    XCFRAMEWORK_OPTIONS[$1]="${XCFRAMEWORK_OPTIONS[$1]} -framework $(readlink -f $SCRATCH)/$(cap_first_letter $1).framework"
}

create_xcframework()
{   
    local XCFRAMEWORK_OUTPUT="$ROOT_DIR/xcframework/$(cap_first_letter $1).xcframework"
    rm -rf $XCFRAMEWORK_OUTPUT
	xcodebuild -create-xcframework ${XCFRAMEWORK_OPTIONS[$1]} -output $XCFRAMEWORK_OUTPUT
    if [ -d "$XCFRAMEWORK_OUTPUT/tvos-arm64" ]; then
        mv $XCFRAMEWORK_OUTPUT/tvos-arm64  $XCFRAMEWORK_OUTPUT/tvos-arm64_arm64e
    fi
}





