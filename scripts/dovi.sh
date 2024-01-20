#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="dovi"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b libdovi-3.2.0 --single-branch https://github.com/quietvoid/dovi_tool.git  $sources_dir
fi

install_cargo()
{
    brew list rustup || brew install rustup
    install_cargo_c
    rustup toolchain install nightly
    rustup component add rust-src --toolchain nightly-x86_64-apple-darwin
    rustup default nightly-x86_64-apple-darwin
}

install_cargo_c()
{
    if [ -z "$(ls -A "$ROOT_DIR/src/cargo-c")" ]; then
        cd $ROOT_DIR
        git clone -b v0.9.29 --single-branch https://github.com/lu-zero/cargo-c.git  src/cargo-c
        cd -
        cd $ROOT_DIR/src/cargo-c
        git apply $ROOT_DIR/patch/cargo-c/tvos_build.patch || true
        cargo install --path .
        cd - 
    fi
}


#support_platform()
#{
#    if [[ "$1" = "tvsimulator" ]]; then
#        echo false
#    elif [[ "$1" = "tvos" ]]; then
#        echo false
#    else
#        echo true
#    fi 
#}

#support_platform_arch()
#{
#    if [[ "$1" = "isimulator" && "$2" = "x86_64" ]]; then
#        echo false
#    else
#        echo true
#    fi 
#}

run_build()
{
    export PATH="$HOME/.cargo/bin:$PATH"

    install_cargo

    cd $ROOT_DIR/$sources_dir/dolby_vision

    if [[ "$ARCH" = "arm64" ]]; then
        ARCH_CPU_FAMILY="aarch64"
    else
        ARCH_CPU_FAMILY="x86_64"
    fi
    if [[ "$PLATFORM" = "macos" ]]; then
        DEPLOYMENT_TARGET="$ARCH_CPU_FAMILY-apple-darwin"
    elif [[ "$PLATFORM" = "ios" ]]; then
        DEPLOYMENT_TARGET="$ARCH_CPU_FAMILY-apple-ios"
    elif [[ "$PLATFORM" = "isimulator" && "$ARCH_CPU_FAMILY" = "aarch64" ]]; then
        DEPLOYMENT_TARGET="$ARCH_CPU_FAMILY-apple-ios-sim"
    elif [[ "$PLATFORM" = "isimulator" && "$ARCH_CPU_FAMILY" = "x86_64" ]]; then
        DEPLOYMENT_TARGET="$ARCH_CPU_FAMILY-apple-ios"
    elif [[ "$PLATFORM" = "tvos" ]]; then
        DEPLOYMENT_TARGET="$ARCH_CPU_FAMILY-apple-tvos"
    elif [[ "$PLATFORM" = "tvsimulator" && "$ARCH_CPU_FAMILY" = "aarch64" ]]; then
        DEPLOYMENT_TARGET="$ARCH_CPU_FAMILY-apple-tvos-sim"
    elif [[ "$PLATFORM" = "tvsimulator" && "$ARCH_CPU_FAMILY" = "x86_64" ]]; then
        DEPLOYMENT_TARGET="$ARCH_CPU_FAMILY-apple-tvos"
    fi

    cargo +nightly build -Z build-std=std,panic_abort --target=$DEPLOYMENT_TARGET
    cargo +nightly cinstall -Z build-std=std,panic_abort --target=$DEPLOYMENT_TARGET --destdir=$BUILDDIR
    cargo clean
    local prefix=$SCRATCH/$ARCH
    sed -i "s|prefix=/usr/local|prefix=${prefix}|" $BUILDDIR/usr/local/lib/pkgconfig/dovi.pc
    mv -f $BUILDDIR/usr/local/lib/pkgconfig/* $BUILDDIR/../lib/pkgconfig/
    rm -rf $BUILDDIR/usr/local/lib/pkgconfig
    mv -f $BUILDDIR/usr/local/lib/* $BUILDDIR/../lib/    
    rm -rf $BUILDDIR/../include/libdovi
    mv -f $BUILDDIR/usr/local/include/* $BUILDDIR/../include/
    cd - 
}

add_lipo_arguments()
{
    create_lipo_arguments "libdovi"
}

run_lipo()
{
    create_lipo "libdovi" "libdovi"
}

add_xcframework_options()
{
    create_xcframework_options "libdovi" 
}

run_xcframework()
{    
    create_xcframework "libdovi"
}

source config.sh



