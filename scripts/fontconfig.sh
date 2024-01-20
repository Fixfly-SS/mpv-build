#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="fontconfig"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b 2.15.0 --single-branch https://gitlab.freedesktop.org/fontconfig/fontconfig.git  $sources_dir
fi

run_build()
{
    cd $ROOT_DIR/$sources_dir
    meson setup $BUILDDIR $MESON_COMMON_OPTIONS -Ddoc=disabled -Dtests=disabled
    meson compile -C $BUILDDIR
    meson install -C $BUILDDIR  
    cd - 
}

add_lipo_arguments()
{
    create_lipo_arguments "libfontconfig"
}

run_lipo()
{
    create_lipo "libfontconfig"
}

add_xcframework_options()
{
    create_xcframework_options "libfontconfig" 
}

run_xcframework()
{    
    create_xcframework "libfontconfig"
}

source config.sh



