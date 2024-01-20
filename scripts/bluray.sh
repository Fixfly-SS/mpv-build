#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="bluray"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b 1.3.4 --single-branch --recurse-submodules --shallow-submodules https://code.videolan.org/videolan/libbluray.git  $sources_dir
fi

run_build()
{
    cd $ROOT_DIR/$sources_dir
    if [[ "$PLATFORM" != "macos" ]]; then
        git apply $ROOT_DIR/patch/libbluray/fix-no-dadisk.patch || true
    fi
    if [[ "$PLATFORM" == "tvos" || "$PLATFORM" == "tvsimulator" ]]; then
        git apply $ROOT_DIR/patch/libbluray/no_fork_and_exec.patch || true
    fi
    ./bootstrap
    if [[ "$PLATFORM" != "macos" && "$PLATFORM" != "maccatalyst" ]]; then
        # sed -i is not working for some reason, so we use a temporary file instead, to investigate later
        sed 's/-framework DiskArbitration//g' configure > tmp.txt && rm configure && mv tmp.txt configure && chmod +x configure
    fi
    cd -
    $ROOT_DIR/$sources_dir/configure $COMMON_OPTIONS  \
                    --disable-fast-install \
                    --disable-bdjava-jar \
                    --disable-dependency-tracking \
                    --disable-silent-rules \
                    --disable-doxygen-doc \
                    --disable-doxygen-dot \
                    --disable-doxygen-html \
                    --disable-doxygen-pdf \
                    --disable-doxygen-ps \
                    --disable-examples \
                    --with-pic \
                    --enable-static \
                    --disable-shared \
                    --without-fontconfig

    make -j5 -s
    make -j5 install -s
    cd $ROOT_DIR/$sources_dir && git stash && cd -
}

add_lipo_arguments()
{
    create_lipo_arguments "libbluray" 
}

run_lipo()
{
    create_lipo "libbluray" "libbluray"
}

add_xcframework_options()
{
    create_xcframework_options "libbluray" 
}

run_xcframework()
{    
    create_xcframework "libbluray"
}

source config.sh



