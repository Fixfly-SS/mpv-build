#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="lcms2"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b lcms2.16 --single-branch https://github.com/mm2/Little-CMS.git  $sources_dir
fi

run_build()
{
    cd $ROOT_DIR/$sources_dir
    meson setup $BUILDDIR $MESON_COMMON_OPTIONS
    meson compile -C $BUILDDIR
    meson install -C $BUILDDIR  
    cd - && cd ..
    mkdir -p ./include/lcms2
    mv ./include/lcms2*.h ./include/lcms2
    sed -i 's|includedir=${prefix}/include|includedir=${prefix}/include/lcms2|' ./lib/pkgconfig/lcms2.pc
    cd -
}

add_lipo_arguments()
{
    create_lipo_arguments "liblcms2"
}

run_lipo()
{
    create_lipo "liblcms2"
}

add_xcframework_options()
{
    create_xcframework_options "liblcms2" 
}

run_xcframework()
{    
    create_xcframework "liblcms2"
}

source config.sh



