#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="gnutls"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b 3.7.10 --single-branch https://github.com/gnutls/gnutls.git  $sources_dir
   brew list gtk-doc || brew install gtk-doc
   brew list libtasn1 || brew install libtasn1 
   cd $sources_dir && ./bootstrap && cd -
fi

run_build()
{
    CFLAGS="$CFLAGS -I$SCRATCH/$ARCH/include/gmp"
    CPPFLAGS=$CFLAGS
    LDFLAGS="$LDFLAGS -L$SCRATCH/$ARCH/lib -lgmp -framework Security -framework CoreFoundation"
    
    $ROOT_DIR/$sources_dir/configure $COMMON_OPTIONS  --disable-fast-install \
                --without-p11-kit \
                --disable-nls \
                --with-included-unistring \
                --with-included-libtasn1 \
                --disable-doc \
                --disable-tests \
                --disable-tools \
                --without-idn \
                --disable-manpages \
                --without-brotli \
                --enable-hardware-acceleration \
                --disable-openssl-compatibility \
                --disable-code-coverage \
                --disable-rpath \
                --disable-maintainer-mode \
                --disable-full-test-suite \
                --without-zlib \
                --without-zstd
    make -j5 -s
    make -j5 install -s
}

add_lipo_arguments()
{
    create_lipo_arguments "libgnutls"
}

run_lipo()
{
    create_lipo "libgnutls"
}

add_xcframework_options()
{
    create_xcframework_options "libgnutls" 
}

run_xcframework()
{    
    create_xcframework "libgnutls"
}

source config.sh



