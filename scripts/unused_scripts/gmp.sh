#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="gmp"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b v6.2.1 --single-branch https://github.com/alisw/GMP.git  $sources_dir
fi

run_build()
{
    $ROOT_DIR/$sources_dir/configure $COMMON_OPTIONS \
                --disable-maintainer-mode \
                --disable-assembly \
                --disable-fast-install
    make -j5 -s
    make -j5 install -s
    cd ..
    mkdir -p ./include/gmp
    mv ./include/gmp.h ./include/gmp
    sed -i 's|includedir=${prefix}/include|includedir=${prefix}/include/gmp|' ./lib/pkgconfig/gmp.pc
    cd -
}

add_lipo_arguments()
{
    create_lipo_arguments "libgmp"
}

run_lipo()
{
    create_lipo "libgmp"
}

add_xcframework_options()
{
    create_xcframework_options "libgmp" 
}

run_xcframework()
{    
    create_xcframework "libgmp"
}

source config.sh



