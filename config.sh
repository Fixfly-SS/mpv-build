#!/usr/local/bin/bash
set -eu

export ONLY_XC  # 如果源代码已经build 用于仅创建xcframework 

while getopts ":x" OPTION; do
    case $OPTION in
    x)
        ONLY_XC=true
        ;;
    ?)
        echo "Invalid option"
        exit 1
        ;;
    esac
done

#-------------------------------------------------------------------------
# 参数

#PLATFORMS="ios isimulator tvos tvsimulator macos"
#ARCHS="x86_64 arm64"
PLATFORMS="ios isimulator tvos tvsimulator macos"

IOS_MIN_VERSION="14.0"
TVOS_MIN_VERSION="14.0"
MACOSX_MIN_VERSION="11.0"

export ROOT_DIR="$(pwd)"

export DEBUG_ENABLED=false
export GPL_ENABLED=false

if [ "$DEBUG_ENABLED" = "true" ]; then
    export debug_flag="-g"
    export buile_type="debug"
    OptimizationLevel=0
else
    export debug_flag=""
    export buile_type="release"
    OptimizationLevel=2
fi

#-------------------------------------------------------------------------

export LC_CTYPE="C"
#export LC_ALL="C"
export CC="/usr/bin/clang"
#export PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/:/usr/local/opt/gnu-sed/libexec/gnubin:/opt/homebrew/bin:$PATH"
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:/opt/homebrew/bin:$PATH"

PKG_DEFAULT_PATH=$(pkg-config --variable pc_path pkg-config)

export PKG_CONFIG_LIBDIR
export SCRATCH
export BUILDDIR

export SDKPATH
export ARCH
export PLATFORM

export LDFLAGS
export CXXFLAGS
export CPPFLAGS
export CMAKE_OSX_ARCHITECTURES

export COMMON_OPTIONS

#-------------------------------------------------------------------------

setDeploymentTarget()
{
    if [[ "$PLATFORM" = "macos" ]]; then
        DEPLOYMENT_TARGET="$ARCH-apple-macos$MACOSX_MIN_VERSION"
    elif [[ "$PLATFORM" = "ios" ]]; then
        DEPLOYMENT_TARGET="$ARCH-apple-ios$IOS_MIN_VERSION"
    elif [[ "$PLATFORM" = "isimulator" ]]; then
        DEPLOYMENT_TARGET="$ARCH-apple-ios$IOS_MIN_VERSION-simulator"
    elif [[ "$PLATFORM" = "tvos" ]]; then
        DEPLOYMENT_TARGET="$ARCH-apple-tvos$TVOS_MIN_VERSION"
    elif [[ "$PLATFORM" = "tvsimulator" ]]; then
        DEPLOYMENT_TARGET="$ARCH-apple-tvos$TVOS_MIN_VERSION-simulator"
    fi
}

#平台
for PLATFORM in $PLATFORMS; do
    if type support_platform &> /dev/null; then
        support_build=$(support_platform $PLATFORM)
        if [[ "$support_build" = "false" ]]; then
            continue
        fi
    fi

    ARCHS="x86_64 arm64"

    if [[ "$PLATFORM" = "macos" ]]; then
        SDK_VERSION=$(xcrun -sdk macosx --show-sdk-version)
        SDKPATH="$(xcrun -sdk macosx --show-sdk-path)"
        OS_MIN_VERSION="-mmacosx-version-min=$MACOSX_MIN_VERSION"
        SDK="MacOSX"
    elif [[ "$PLATFORM" = "ios" ]]; then
        ARCHS="arm64"
        SDK_VERSION=$(xcrun -sdk iphoneos --show-sdk-version)
        SDKPATH="$(xcrun -sdk iphoneos --show-sdk-path)"
        OS_MIN_VERSION="-mios-version-min=$IOS_MIN_VERSION"
        SDK="iPhoneOS"
    elif [[ "$PLATFORM" = "isimulator" ]]; then
        SDK_VERSION=$(xcrun -sdk iphonesimulator --show-sdk-version)
        SDKPATH="$(xcrun -sdk iphonesimulator --show-sdk-path)"
        OS_MIN_VERSION="-mios-simulator-version-min=$IOS_MIN_VERSION"
        SDK="iPhoneSimulator"
    elif [[ "$PLATFORM" = "tvos" ]]; then
        ARCHS="arm64"
        SDK_VERSION=$(xcrun -sdk appletvos --show-sdk-version)
        SDKPATH="$(xcrun -sdk appletvos --show-sdk-path)"
        OS_MIN_VERSION="-mtvos-version-min=$TVOS_MIN_VERSION"
        SDK="AppleTVOS"
    elif [[ "$PLATFORM" = "tvsimulator" ]]; then
        SDK_VERSION=$(xcrun -sdk appletvsimulator --show-sdk-version)
        SDKPATH="$(xcrun -sdk appletvsimulator --show-sdk-path)"
        OS_MIN_VERSION="-mtvos-simulator-version-min=$TVOS_MIN_VERSION"
        SDK="AppleTVSimulator"
    fi

    #处理器架构
    for ARCH in $ARCHS; do
        if type support_platform_arch &> /dev/null; then
            support_build=$(support_platform_arch $PLATFORM $ARCH)
            if [[ "$support_build" = "false" ]]; then
                continue
            fi
        fi
        setDeploymentTarget
        LDFLAGS="-lc++ -arch $ARCH -isysroot $SDKPATH -target $DEPLOYMENT_TARGET $OS_MIN_VERSION"
        CFLAGS="-fno-common -arch $ARCH -isysroot $SDKPATH -target $DEPLOYMENT_TARGET $OS_MIN_VERSION"

        if [[ $PLATFORM = "tvos" || $PLATFORM = "tvsimulator" ]]; then
            CFLAGS="$CFLAGS -DHAVE_FORK=0"
        fi

        CFLAGS="$CFLAGS $debug_flag -O$OptimizationLevel"
        CXXFLAGS="$CFLAGS"
        CPPFLAGS="$CFLAGS"
        CMAKE_OSX_ARCHITECTURES=$ARCH

        SCRATCH="$ROOT_DIR/build/scratch-$PLATFORM"
        PKG_CONFIG_LIBDIR="$SCRATCH/$ARCH/lib/pkgconfig:$PKG_DEFAULT_PATH"
        export PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR

        export HOSTFLAG
        if [[ $PLATFORM = "macos" ]]; then
            HOSTFLAG_PLATFORM="apple"
        elif [[ $PLATFORM = "ios" || $PLATFORM = "isimulator" ]]; then
            HOSTFLAG_PLATFORM="ios"
        elif [[ $PLATFORM = "tvos" || $PLATFORM = "tvsimulator" ]]; then
            HOSTFLAG_PLATFORM="tvos"
        fi
        HOSTFLAG="$ARCH-$HOSTFLAG_PLATFORM-darwin"

        export COMMON_OPTION_PREFIX="--prefix=$SCRATCH/$ARCH"
        COMMON_OPTIONS="$COMMON_OPTION_PREFIX --enable-static \
            --disable-shared --disable-dependency-tracking --with-pic --host=$HOSTFLAG --with-sysroot=$SDKPATH"
        export MESON_COMMON_OPTIONS="-Dprefix=$SCRATCH/$ARCH -Dbuildtype=$buile_type -Ddefault_library=static --cross-file=$ROOT_DIR/meson/$PLATFORM-$ARCH.txt"

        # 开始构建
        BUILDDIR=$SCRATCH/$ARCH/$LIBRARY
        echo "building $LIBRARY for $PLATFORM $ARCH"
        rm -fr $BUILDDIR
        mkdir -p $BUILDDIR && cd $_
        
        if [ ! -v ONLY_XC ]; then 
           run_build
        fi
        add_lipo_arguments 
    done
    run_lipo
    add_xcframework_options
done 

run_xcframework

