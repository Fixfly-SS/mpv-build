#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="placebo"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b v6.338.1 --single-branch https://github.com/haasn/libplacebo.git  $sources_dir
   cd $sources_dir
   git submodule update --init --recursive
   cd -
fi

run_build()
{
    cd $ROOT_DIR/$sources_dir
    # if !ios -Dlibdovi=disabled
    meson setup $BUILDDIR $MESON_COMMON_OPTIONS -Dtests=false -Ddemos=false -Dxxhash=disabled -Dunwind=disabled
    meson compile -C $BUILDDIR
    meson install -C $BUILDDIR
    cd -
}

add_lipo_arguments()
{
    create_lipo_arguments "libplacebo"
}

run_lipo()
{
    create_lipo "libplacebo" "libplacebo"
}

add_xcframework_options()
{
    create_xcframework_options "libplacebo" 
}

run_xcframework()
{    
    create_xcframework "libplacebo"
}

source config.sh



