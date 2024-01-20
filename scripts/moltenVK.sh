#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="moltenVK"

sources_dir="src/$LIBRARY"
molten_make_arg=""

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b v1.2.7-rc2 --single-branch https://github.com/KhronosGroup/MoltenVK.git  $sources_dir
   cd $sources_dir
   ./fetchDependencies --none --keep-cache
   cd - 
fi

run_build()
{
    local molten_make_arg=$PLATFORM
    if [[ "$PLATFORM" = "isimulator" ]]; then
        molten_make_arg="iossim"
    elif [[ "$PLATFORM" = "tvsimulator" ]]; then
        molten_make_arg="tvossim"
    fi
    local lib_dir=$(get_lib_dir "$ROOT_DIR/$sources_dir/Package/Release/MoltenVK/MoltenVK.xcframework")
    if [ ! -d "$lib_dir" ]; then
        cd $ROOT_DIR/$sources_dir
        ./fetchDependencies --$molten_make_arg --keep-cache
        make $molten_make_arg
        cd - 
    fi
    xc_MoltenVK
    xc_spirv_cross
}



add_lipo_arguments() 
{
    :
}

run_lipo()
{
    create_lipo_arguments "libmoltenVK" "libMoltenVK"
    create_lipo "libmoltenVK" "MoltenVK" "vk_video" "vulkan"

    create_lipo_arguments "libspirvcross" "libSPIRVCross"
    create_lipo "libspirvcross" "spirv_cross"
}

add_xcframework_options()
{
    create_xcframework_options "libmoltenVK" 
    create_xcframework_options "libspirvcross" 
}

run_xcframework()
{    
    create_xcframework "libmoltenVK"
    create_xcframework "libspirvcross" 
}

get_lib_dir()
{
    local from=$1
    local findname="$PLATFORM*$ARCH"
    if [[ "$PLATFORM" = "isimulator" ]]; then
        findname="ios*simulator"
    elif [[ "$PLATFORM" = "tvsimulator" ]]; then
        findname="tvos*simulator"
    elif [[ "$PLATFORM" = "tvos" ]]; then
        findname="$PLATFORM*arm64e"
    elif [[ "$PLATFORM" = "macos" ]]; then
        findname="$PLATFORM*x86_64"
    fi
    echo $(find $from -type d -name $findname)
}

xc_MoltenVK(){
    # copy  headers
    cd ..
    rm -rf ./include/MoltenVK && rm -rf ./include/vk_video && rm -rf ./include/vulkan
    cp -r $ROOT_DIR/$sources_dir/Package/Release/MoltenVK/include/*  ./include/
    # copy libMoltenVK.a
    rm -rf ./lib/libMoltenVK.a
    local lib_dir=$(get_lib_dir "$ROOT_DIR/$sources_dir/Package/Release/MoltenVK/MoltenVK.xcframework")
    cp -r $lib_dir/libMoltenVK.a  ./lib/
    # pkgconfig
    local prefix=$SCRATCH/$ARCH

    local FRAMEWORKS=" -framework Metal -framework QuartzCore -framework CoreFoundation -framework Foundation -framework IOSurface -framework CoreGraphics -lc++"
    if [[ "$PLATFORM" = "ios" ]]; then
        FRAMEWORKS="$FRAMEWORKS -framework IOKit -framework UIKit "
    elif [[ "$PLATFORM" = "tvos" ]]; then
        FRAMEWORKS="$FRAMEWORKS -framework UIKit "
    elif [[ "$PLATFORM" = "macos" ]]; then
        FRAMEWORKS="$FRAMEWORKS -framework IOKit -framework APPKit -framework Cocoa"
    elif [[ "$PLATFORM" = "maccatalyst" ]]; then
        FRAMEWORKS="$FRAMEWORKS -framework IOKit -framework APPKit -framework UIKit "
    elif [[ "$PLATFORM" = "isimulator" ]]; then
        FRAMEWORKS="$FRAMEWORKS -framework UIKit -framework IOKit"
    elif [[ "$PLATFORM" = "tvsimulator" ]]; then
        FRAMEWORKS="$FRAMEWORKS -framework UIKit "
    fi

    cat <<'EOF' | sed "s|\$prefix|$prefix|g" | sed "s|\$FRAMEWORKS|$FRAMEWORKS|g" > $prefix/lib/pkgconfig/vulkan.pc
prefix=$prefix
includedir=${prefix}/include
libdir=${prefix}/lib

Name: Vulkan-Loader
Description: Vulkan Loader
Version: 1.3.268.1
Libs: -L${libdir} -lMoltenVK $FRAMEWORKS
Cflags: -I${includedir}
EOF

    cd -
} 

xc_spirv_cross(){
    cd ..
    # headers
    rm -rf ./include/spirv_cross
    cp -r $ROOT_DIR/$sources_dir/External/SPIRV-Cross/include/*  ./include/

    #lib.a
    rm -rf ./lib/libSPIRVCross.a
    local lib_dir=$(get_lib_dir "$ROOT_DIR/$sources_dir/External/build/Release/SPIRVCross.xcframework")
    cp -r $lib_dir/libSPIRVCross.a  ./lib/
    
    #.pc
    #moltenVK/External/SPIRV-Cross/pkg-config
    rm -rf ./lib/pkgconfig/spirv-cross-c-shared.pc && rm -rf ./lib/pkgconfig/spirv-cross-c.pc
    cp -r $ROOT_DIR/$sources_dir/External/SPIRV-Cross/pkg-config/*  ./lib/pkgconfig/
    mv ./lib/pkgconfig/spirv-cross-c-shared.pc.in ./lib/pkgconfig/spirv-cross-c-shared.pc
    mv ./lib/pkgconfig/spirv-cross-c.pc.in ./lib/pkgconfig/spirv-cross-c.pc

    local prefix=$SCRATCH/$ARCH
    sed -i "s|@CMAKE_INSTALL_PREFIX@|${prefix}|" ./lib/pkgconfig/spirv-cross-c-shared.pc
    sed -i "s|@CMAKE_INSTALL_PREFIX@|${prefix}|" ./lib/pkgconfig/spirv-cross-c.pc
    sed -i "s|@CMAKE_INSTALL_LIBDIR@|lib|" ./lib/pkgconfig/spirv-cross-c-shared.pc
    sed -i "s|@CMAKE_INSTALL_LIBDIR@|lib|" ./lib/pkgconfig/spirv-cross-c.pc
    sed -i "s|@CMAKE_INSTALL_INCLUDEDIR@|include|" ./lib/pkgconfig/spirv-cross-c-shared.pc
    sed -i "s|@CMAKE_INSTALL_INCLUDEDIR@|include|" ./lib/pkgconfig/spirv-cross-c.pc
    sed -i "s|@SPIRV_CROSS_VERSION@|vulkan-sdk-1.3.268.0|" ./lib/pkgconfig/spirv-cross-c-shared.pc
    sed -i "s|@SPIRV_CROSS_VERSION@|vulkan-sdk-1.3.268.0|" ./lib/pkgconfig/spirv-cross-c.pc
    sed -i "s|-lspirv-cross-c-shared|-lSPIRVCross|" ./lib/pkgconfig/spirv-cross-c-shared.pc
    sed -i "s|-lspirv-cross-c|-lSPIRVCross|" ./lib/pkgconfig/spirv-cross-c.pc

    cd -
}

source config.sh