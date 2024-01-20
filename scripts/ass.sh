#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="ass"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b 0.17.1 --single-branch https://github.com/libass/libass.git  $sources_dir
fi

run_build()
{
    cd $ROOT_DIR/$sources_dir && ./autogen.sh && cd -
    $ROOT_DIR/$sources_dir/configure $COMMON_OPTIONS --disable-libtool-lock \
                 --with-pic \
                 --enable-static \
                 --disable-shared \
				 --disable-test \
                 --disable-profile \
                 --disable-asm \
                 --disable-directwrite \
                 --disable-fast-install

    make -j5 -s
    make -j5 install -s
}

add_lipo_arguments()
{
    create_lipo_arguments "libass"
}

run_lipo()
{
    create_lipo "libass"
}

add_xcframework_options()
{
    create_xcframework_options "libass" 
}

run_xcframework()
{    
    create_xcframework "libass"
}

source config.sh



