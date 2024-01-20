#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="readline"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
   git clone -b readline-8.2 --single-branch https://git.savannah.gnu.org/git/readline.git  $sources_dir
fi

run_build()
{
    $ROOT_DIR/$sources_dir/configure $COMMON_OPTIONS
    make -j5 -s
    make -j5 install -s
}

add_lipo_arguments()
{
    create_lipo_arguments "libreadline"
}

run_lipo()
{
    create_lipo "libreadline"
}

add_xcframework_options()
{
    create_xcframework_options "libreadline" 
}

run_xcframework()
{    
    create_xcframework "libreadline"
}

source config.sh



