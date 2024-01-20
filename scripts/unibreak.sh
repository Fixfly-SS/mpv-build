#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="unibreak"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b libunibreak_5_1 --single-branch https://github.com/adah1972/libunibreak.git  $sources_dir
   cd $sources_dir && mkdir temp && cd -
   cd $sources_dir/temp && ../autogen.sh && cd -
fi



run_build()
{
    mkdir -p $SCRATCH/$ARCH/include/$LIBRARY   
    $ROOT_DIR/$sources_dir/configure $COMMON_OPTIONS --enable-static \
            --disable-fast-install \
            --disable-shared \
            --disable-dependency-tracking \
            --includedir=$SCRATCH/$ARCH/include/$LIBRARY \
            --host=$HOSTFLAG

    make -j5 -s
    make -j5 install -s
}

add_lipo_arguments()
{
    create_lipo_arguments "libunibreak"
}

run_lipo()
{
    create_lipo "libunibreak"
}

add_xcframework_options()
{
    create_xcframework_options "libunibreak" 
}

run_xcframework()
{    
    create_xcframework "libunibreak"
}

source config.sh



