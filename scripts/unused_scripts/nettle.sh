#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="nettle"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b nettle_3.8.1_release_20220727 --single-branch https://github.com/gnutls/nettle.git  $sources_dir
fi

run_build()
{
    CFLAGS="$CFLAGS -I$SCRATCH/$ARCH/include/gmp"
    CPPFLAGS=$CFLAGS
    LDFLAGS="$LDFLAGS -L$SCRATCH/$ARCH/lib -lgmp"
    
    cd $ROOT_DIR/$sources_dir && ./.bootstrap && cd -
    $ROOT_DIR/$sources_dir/configure $COMMON_OPTIONS  --disable-assembler \
                --disable-openssl \
                --disable-gcov \
                --disable-documentation \
                --disable-fast-install \
    make -j5 -s
    make -j5 install -s
}

add_lipo_arguments()
{
    create_lipo_arguments "libnettle"
}

run_lipo()
{
    create_lipo "libnettle"
}

add_xcframework_options()
{
    create_xcframework_options "libnettle" 
}

run_xcframework()
{    
    create_xcframework "libnettle"
}

source config.sh



