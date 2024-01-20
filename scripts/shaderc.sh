#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="shaderc"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
    git clone -b v2023.8 --single-branch https://github.com/google/shaderc.git  $sources_dir
    cd $sources_dir && ./utils/git-sync-deps && cd -
    cd $sources_dir/third_party/spirv-tools  
    git apply ../../../../patch/shaderc/spirv-tools.patch
    cd -
fi

run_build()
{    
    cmake -Wno-dev \
                -GNinja \
                -DSHADERC_SKIP_TESTS=ON \
                -DSHADERC_SKIP_EXAMPLES=ON \
                -DENABLE_EXCEPTIONS=ON \
                -DENABLE_CTEST=OFF \
                -DENABLE_GLSLANG_BINARIES=OFF \
                -DSPIRV_SKIP_EXECUTABLES=ON \
                -DBUILD_SHARED_LIBS=false \
                -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_PREFIX_PATH=$SCRATCH/$ARCH \
                -DCMAKE_INSTALL_PREFIX=$SCRATCH/$ARCH \
                -DCMAKE_OSX_SYSROOT=$SDKPATH \
                $ROOT_DIR/$sources_dir
           
    ninja
    ninja install
    mv $SCRATCH/$ARCH/lib/pkgconfig/shaderc.pc $SCRATCH/$ARCH/lib/pkgconfig/shaderc_shared.pc
    mv $SCRATCH/$ARCH/lib/pkgconfig/shaderc_combined.pc $SCRATCH/$ARCH/lib/pkgconfig/shaderc.pc 
}

createGlslangHeader()
{
    cd ..
    rm -rf ./include/glslang
    mkdir -p ./include/glslang/HLSL
    mkdir -p ./include/glslang/Include
    mkdir -p ./include/glslang/MachineIndependent/preprocessor
    mkdir -p ./include/glslang/Public
    mkdir -p ./include/glslang/SPIRV
    cp $ROOT_DIR/$sources_dir/third_party/glslang/glslang/HLSL/*.h  ./include/glslang/HLSL
    cp $ROOT_DIR/$sources_dir/third_party/glslang/glslang/Include/*.h  ./include/glslang/Include
    cp $ROOT_DIR/$sources_dir/third_party/glslang/glslang/MachineIndependent/preprocessor/*.h  ./include/glslang/MachineIndependent/preprocessor
    cp $ROOT_DIR/$sources_dir/third_party/glslang/glslang/MachineIndependent/*.h  ./include/glslang/MachineIndependent
    cp $ROOT_DIR/$sources_dir/third_party/glslang/glslang/Public/*.h  ./include/glslang/Public
    cp $ROOT_DIR/$sources_dir/third_party/glslang/SPIRV/*.h  ./include/glslang/SPIRV
    cp $ROOT_DIR/$sources_dir/third_party/glslang/build_info.h.tmpl  ./include/glslang/build_info.h
    cd -
}

add_lipo_arguments()
{
    createGlslangHeader
    create_lipo_arguments "libshaderc" "libshaderc_combined"
}

run_lipo()
{
    create_lipo "libshaderc" "shaderc" "spirv-tools" "glslang"
}

add_xcframework_options()
{
    create_xcframework_options "libshaderc" 
}

run_xcframework()
{    
    create_xcframework "libshaderc"
}

source config.sh



