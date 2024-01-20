#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="harfbuzz"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b 8.3.0 --single-branch https://github.com/harfbuzz/harfbuzz.git $sources_dir
fi

run_build()
{
    cd $ROOT_DIR/$sources_dir
    meson setup $BUILDDIR $MESON_COMMON_OPTIONS -Dglib=disabled -Ddocs=disabled -Dtests=disabled
    meson compile -C $BUILDDIR
    meson install -C $BUILDDIR  
    cd - 
}

add_lipo_arguments()
{
    create_lipo_arguments "libharfbuzz"
    create_lipo_arguments "libharfbuzz-subset"
}

run_lipo()
{
    create_lipo "libharfbuzz"
    create_lipo "libharfbuzz-subset"
}

add_xcframework_options()
{
    create_xcframework_options "libharfbuzz" 
    create_xcframework_options "libharfbuzz-subset" 
}

run_xcframework()
{    
    create_xcframework "libharfbuzz"
    create_xcframework "libharfbuzz-subset"
}

source config.sh



