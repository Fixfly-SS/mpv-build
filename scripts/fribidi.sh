#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="fribidi"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b v1.0.13 --single-branch https://github.com/fribidi/fribidi.git  $sources_dir
fi

run_build()
{
    cd $ROOT_DIR/$sources_dir
    meson setup $BUILDDIR $MESON_COMMON_OPTIONS -Ddeprecated=false -Ddocs=false -Dtests=false
    meson compile -C $BUILDDIR
    meson install -C $BUILDDIR  
    cd - 
}

add_lipo_arguments()
{
    create_lipo_arguments "libfribidi"
}

run_lipo()
{
    create_lipo "libfribidi"
}

add_xcframework_options()
{
    create_xcframework_options "libfribidi" 
}

run_xcframework()
{    
    create_xcframework "libfribidi"
}

source config.sh



