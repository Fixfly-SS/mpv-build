#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="uchardet"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b v0.0.8 --single-branch https://gitlab.freedesktop.org/uchardet/uchardet.git  $sources_dir
fi

run_build()
{
    local ENABLE_MONOTONIC_CLOCK=1
    cmake $ROOT_DIR/$sources_dir -Wno-dev \
             -Ddefault_library=static \
             -DCMAKE_VERBOSE_MAKEFILE=0 \
             -DBUILD_SHARED_LIBS=0 \
             -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_PREFIX_PATH=$SCRATCH/$ARCH \
             -DCMAKE_INSTALL_PREFIX=$SCRATCH/$ARCH \
             -DCMAKE_OSX_SYSROOT=$SDKPATH \
             -DCMAKE_OSX_ARCHITECTURES=$ARCH \
             -DENABLE_STDCXX_SYNC=1 \
             -DENABLE_CXX11=1 \
             -DENABLE_DEBUG=0 \
             -DENABLE_LOGGING=0 \
             -DENABLE_HEAVY_LOGGING=0 \
             -DENABLE_APPS=0 \
             -DENABLE_SHARED=0 \
             -DENABLE_MONOTONIC_CLOCK=1
    make -j5 -s
    make -j5 install -s    
}

add_lipo_arguments()
{
    create_lipo_arguments "libuchardet"
}

run_lipo()
{
    create_lipo "libuchardet"
}

add_xcframework_options()
{
    create_xcframework_options "libuchardet" 
}

run_xcframework()
{    
    create_xcframework "libuchardet"
}

source config.sh



