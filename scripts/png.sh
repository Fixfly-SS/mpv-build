#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="png"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
    git clone -b v1.6.40 --single-branch https://github.com/glennrp/libpng.git  $sources_dir
fi

run_build()
{
    #-DPNG_HARDWARE_OPTIMIZATIONS
    $ROOT_DIR/$sources_dir/configure $COMMON_OPTIONS
    make -j5 -s
    make -j5 install -s
}

add_lipo_arguments()
{
    create_lipo_arguments "libpng" "libpng16"
}

run_lipo()
{
    create_lipo "libpng" "libpng16"
}

add_xcframework_options()
{
    create_xcframework_options "libpng"
}

run_xcframework()
{    
    create_xcframework "libpng"
}

source config.sh



