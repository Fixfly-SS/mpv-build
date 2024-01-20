#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="openssl"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b openssl-3.2.0 --single-branch https://github.com/openssl/openssl.git  $sources_dir
fi

run_build()
{
    architecture="darwin64-$ARCH"
    #arch == .x86_64 ? "darwin64-x86_64" : arch == .arm64e ? "iphoneos-cross" : "darwin64-arm64",
    $ROOT_DIR/$sources_dir/Configure $COMMON_OPTION_PREFIX $architecture no-async no-shared no-dso no-engine no-tests
    make -j5 -s
    make -j5 install -s
}

add_lipo_arguments()
{
    create_lipo_arguments "libssl"
    create_lipo_arguments "libcrypto"
}

run_lipo()
{
    create_lipo "libssl"
    create_lipo "libcrypto"
}

add_xcframework_options()
{
    create_xcframework_options "libssl" 
    create_xcframework_options "libcrypto" 
}

run_xcframework()
{    
    create_xcframework "libssl"
    create_xcframework "libcrypto"
}

source config.sh



