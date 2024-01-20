#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="luajit"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b v2.1.ROLLING --single-branch https://github.com/LuaJIT/LuaJIT.git  $sources_dir
fi

support_platform()
{
    if [[ "$1" = "maccatalyst" ]]; then
        echo false
    else
        echo true
    fi 
}

support_platform_arch()
{
    #if [[ "$1" = "macos" && "$2" = "arm64" ]]; then
    #    echo false
    #else
    #    echo true
    #fi 
    echo true
}

run_build()
{
    cd $ROOT_DIR/$sources_dir
    PREFIX=$SCRATCH/$ARCH
    make clean MACOSX_DEPLOYMENT_TARGET=$MACOSX_MIN_VERSION
    TARGET_FLAGS="-arch $ARCH -isysroot $SDKPATH"
    CROSS="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
    if [[ "$PLATFORM" = "macos" ]]; then
        env -i make -j5 -s MACOSX_DEPLOYMENT_TARGET=$MACOSX_MIN_VERSION PREFIX=$PREFIX DEFAULT_CC=clang CROSS=$CROSS TARGET_FLAGS="$TARGET_FLAGS"
    else
        env -i make -j5 -s PREFIX=$PREFIX DEFAULT_CC=clang CROSS=$CROSS TARGET_FLAGS="$TARGET_FLAGS" TARGET_SYS=iOS
    fi
    make -j5 install -s PREFIX=$PREFIX
}

add_lipo_arguments()
{
    create_lipo_arguments "libluajit" "libluajit-5.1"
}

run_lipo()
{
    create_lipo "libluajit" "luajit-2.1"
}

add_xcframework_options()
{
    create_xcframework_options "libluajit" 
}

run_xcframework()
{    
    create_xcframework "libluajit"
}

source config.sh



