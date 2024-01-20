#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="dav1d"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b 1.3.0 --single-branch https://github.com/videolan/dav1d.git  $sources_dir
fi

run_build()
{
    cd $ROOT_DIR/$sources_dir
    meson setup $BUILDDIR $MESON_COMMON_OPTIONS -Denable_asm=true -Denable_tools=false -Denable_examples=false -Denable_tests=false
    meson compile -C $BUILDDIR
    meson install -C $BUILDDIR
    cd - 
}

add_lipo_arguments()
{
    create_lipo_arguments "libdav1d"
}

run_lipo()
{
    create_lipo "libdav1d"
}

add_xcframework_options()
{
    create_xcframework_options "libdav1d" 
}

run_xcframework()
{    
    create_xcframework "libdav1d"
}

source config.sh



