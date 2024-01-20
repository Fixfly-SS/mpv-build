#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="freetype"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b VER-2-13-2 --single-branch https://github.com/freetype/freetype.git $sources_dir
fi

run_build()
{
    # VER-2-10-1以上版本需要依赖libbrotli库，或指定--with-brotli=no
    cd $ROOT_DIR/$sources_dir
    OPT="-Dbrotli=disabled"
    meson setup $BUILDDIR $OPT $MESON_COMMON_OPTIONS
    meson compile -C $BUILDDIR
    meson install -C $BUILDDIR 
    cd - 
}

add_lipo_arguments()
{
    create_lipo_arguments "libfreetype" 
}

run_lipo()
{
    create_lipo "libfreetype" "freetype2"
}

add_xcframework_options()
{
    create_xcframework_options "libfreetype" 
}

run_xcframework()
{    
    create_xcframework "libfreetype"
}

source config.sh



