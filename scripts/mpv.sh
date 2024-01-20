#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="mpv"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b v0.37.0 --single-branch https://github.com/mpv-player/mpv.git $sources_dir
   cd $sources_dir
   git apply ../../patch/mpv/molten-vk-context.patch
   cd -
fi

run_build()
{
    cd $ROOT_DIR/$sources_dir
    #-Dspirv-cross=disabled
    opts="-Dlibmpv=true -Dzimg=disabled  -Djpeg=disabled -Drubberband=disabled \
            -Dplain-gl=enabled -Dvulkan=enabled  \
            -Diconv=enabled -Duchardet=enabled -Dlibbluray=enabled"            

    if [[ "$PLATFORM" = "macos" && $(uname -m) == $ARCH ]]; then
        opts="$opts -Dcplayer=true"
    else 
        opts="$opts -Dcplayer=false"
    fi

    if [ "$GPL_ENABLED" = "true" ]; then
        opts="$opts -Dgpl=true"
    else
        opts="$opts -Dgpl=false"
    fi
    opts="$opts -Dlua=luajit"
    #if [[ "$PLATFORM" == "maccatalyst" ]]; then
    #    opts="$opts -Dlua=disabled"
    #elif [[ "$PLATFORM" == "macos" ]]; then
    #    opts="$opts -Dlua=enabled"
    #else
    #    opts="$opts -Dlua=luajit"
    #fi
    if [[ "$PLATFORM" = "macos" ]]; then
        opts="$opts -Dcocoa=enabled -Dcoreaudio=enabled -Dgl-cocoa=enabled -Dvideotoolbox-gl=enabled"
    else
        #if [[ "$PLATFORM" = "maccatalyst" ]]; then
        #    opts="$opts -Dcocoa=disabled -Dcoreaudio=disabled"
        #fi
        opts="$opts -Dswift-build=disabled -Dvideotoolbox-gl=disabled -Dios-gl=enabled"
    fi
    meson setup $BUILDDIR $MESON_COMMON_OPTIONS $opts -Dswift-flags="-sdk $SDKPATH -target $ARCH-apple-macos11.0"
    meson compile -C $BUILDDIR
    meson install -C $BUILDDIR
    cd -
}

add_lipo_arguments()
{
    create_lipo_arguments "libmpv"
}

run_lipo()
{
    create_lipo "libmpv"
}

add_xcframework_options()
{
    create_xcframework_options "libmpv" 
}

run_xcframework()
{    
    create_xcframework "libmpv"
}

source config.sh



