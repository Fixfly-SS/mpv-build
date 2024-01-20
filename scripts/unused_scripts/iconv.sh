#!/usr/local/bin/bash



# 一般系统提供不需要构建 自己构建反而会和系统的产生冲突,出现问题


set -eu
source utils.sh

export LIBRARY="iconv"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b v1.17 --single-branch https://github.com/roboticslibrary/libiconv.git  $sources_dir
   cd $ROOT_DIR/$sources_dir
   brew list groff || brew install groff
   ./gitsub.sh pull && ./autogen.sh && cd -
fi

run_build()
{
    mkdir -p $SCRATCH/$ARCH/include/$LIBRARY
    $ROOT_DIR/$sources_dir/configure $COMMON_OPTIONS \
            --enable-static \
            --disable-shared \
            --disable-fast-install \
            --enable-extra-encodings \
            --disable-libtool-lock \
            --disable-test \
            --disable-dependency-tracking \
            --includedir=$SCRATCH/$ARCH/include/$LIBRARY \
            --host=$HOSTFLAG
 #--disable-shared \

    make -j5 -s
    make -j5 install -s
    
    local prefix=$SCRATCH/$ARCH
    cat <<'EOF' | sed "s|\$prefix|$prefix|g" > $prefix/lib/pkgconfig/libiconv.pc
prefix=$prefix
includedir=${prefix}/include/iconv
libdir=${prefix}/lib

Name: libiconv
Description: Library for convert from/to Unicode
Version: v1.17
Libs: -L${libdir} -liconv
Cflags: -I${includedir}
EOF

}

add_lipo_arguments()
{
    create_lipo_arguments "libiconv"
}

run_lipo()
{
    create_lipo "libiconv"
}

add_xcframework_options()
{
    create_xcframework_options "libiconv" 
}

run_xcframework()
{    
    create_xcframework "libiconv"
}

source config.sh



