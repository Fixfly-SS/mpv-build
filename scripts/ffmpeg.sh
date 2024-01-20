#!/usr/local/bin/bash
set -eu
source utils.sh

export LIBRARY="ffmpeg"

sources_dir="src/$LIBRARY"

if [ -z "$(ls -A $sources_dir)" ]; then
    git clone -b n6.1.1 --single-branch https://github.com/FFmpeg/FFmpeg.git  $sources_dir
    cd $sources_dir
    git apply ../../patch/ffmpeg/ffmpeg.patch 
    cd -
fi

confugure()
{
    # Configuration options #--disable-iconv
    FFMPEG_OPTIONS="$FFMPEG_OPTIONS --disable-armv5te --disable-armv6 --disable-armv6t2 \
    --disable-bzlib --disable-gray  --disable-linux-perf \
    --disable-shared --disable-small --disable-swscale-alpha --disable-symver --disable-xlib \
    --enable-cross-compile --enable-gpl --enable-libxml2 --enable-nonfree --enable-optimizations \
    --enable-pic --enable-runtime-cpudetect --enable-static  --enable-thumb --enable-version3 \
    --pkg-config-flags=--static "  
    
    # Documentation options
    FFMPEG_OPTIONS="$FFMPEG_OPTIONS --disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages "  

    # Component options
    FFMPEG_OPTIONS="$FFMPEG_OPTIONS --enable-avcodec --enable-avformat --enable-avutil --enable-network \
    --enable-swresample --enable-swscale  --disable-devices --disable-outdevs --disable-indevs --disable-postproc "  

    # Hardware accelerators
    FFMPEG_OPTIONS="$FFMPEG_OPTIONS  --disable-d3d11va --disable-dxva2 --disable-vaapi --disable-vdpau " 

    # muxers
    FFMPEG_OPTIONS="$FFMPEG_OPTIONS  --disable-muxers --enable-muxer=flac --enable-muxer=dash --enable-muxer=hevc \
    --enable-muxer=m4v --enable-muxer=matroska --enable-muxer=mov --enable-muxer=mp4 --enable-muxer=mpegts --enable-muxer=webm* "

    # encoders
    FFMPEG_OPTIONS="$FFMPEG_OPTIONS   --disable-encoders --enable-encoder=aac --enable-encoder=alac --enable-encoder=flac \
    --enable-encoder=pcm* --enable-encoder=movtext --enable-encoder=mpeg4 --enable-encoder=h264_videotoolbox \
    --enable-encoder=hevc_videotoolbox --enable-encoder=prores --enable-encoder=prores_videotoolbox "

    # protocols bsfs
    FFMPEG_OPTIONS="$FFMPEG_OPTIONS  --enable-protocols --enable-bsfs \
    --disable-protocol=ffrtmpcrypt --disable-protocol=gopher --disable-protocol=icecast \
    --disable-protocol=librtmp* --disable-protocol=libssh --disable-protocol=md5 --disable-protocol=mmsh \
    --disable-protocol=mmst --disable-protocol=sctp --disable-protocol=subfile --disable-protocol=unix "

    # demuxers
    FFMPEG_OPTIONS="$FFMPEG_OPTIONS  --disable-demuxers  --enable-demuxer=aac --enable-demuxer=ac3 --enable-demuxer=aiff \
    --enable-demuxer=amr --enable-demuxer=ape --enable-demuxer=asf --enable-demuxer=ass --enable-demuxer=av1 \
    --enable-demuxer=avi --enable-demuxer=caf --enable-demuxer=concat --enable-demuxer=dash --enable-demuxer=data \
    --enable-demuxer=dv --enable-demuxer=eac3 --enable-demuxer=flac --enable-demuxer=flv --enable-demuxer=h264 \
    --enable-demuxer=hevc --enable-demuxer=hls --enable-demuxer=live_flv --enable-demuxer=loas --enable-demuxer=m4v \
    --enable-demuxer=matroska --enable-demuxer=mov --enable-demuxer=mp3 --enable-demuxer=mpeg* --enable-demuxer=ogg \
    --enable-demuxer=rm --enable-demuxer=rtsp --enable-demuxer=rtp --enable-demuxer=srt --enable-demuxer=vc1 \
    --enable-demuxer=wav --enable-demuxer=webm_dash_manifest "

    # decoders
    FFMPEG_OPTIONS="$FFMPEG_OPTIONS  --disable-decoders "

    # 视频
    FFMPEG_OPTIONS="$FFMPEG_OPTIONS  --enable-decoder=av1 --enable-decoder=dca --enable-decoder=dxv \
    --enable-decoder=ffv1 --enable-decoder=ffvhuff --enable-decoder=flv --enable-decoder=h263 \
    --enable-decoder=h263i --enable-decoder=h263p --enable-decoder=h264 \
    --enable-decoder=hap --enable-decoder=hevc --enable-decoder=huffyuv \
    --enable-decoder=indeo5 \
    --enable-decoder=mjpeg --enable-decoder=mjpegb --enable-decoder=mpeg* --enable-decoder=mts2 \
    --enable-decoder=prores \
    --enable-decoder=mpeg4 --enable-decoder=mpegvideo \
    --enable-decoder=rv10 --enable-decoder=rv20 --enable-decoder=rv30 --enable-decoder=rv40 \
    --enable-decoder=snow --enable-decoder=svq3 \
    --enable-decoder=tscc --enable-decoder=txd \
    --enable-decoder=wmv1 --enable-decoder=wmv2 --enable-decoder=wmv3 \
    --enable-decoder=vc1 --enable-decoder=vp6 --enable-decoder=vp6a --enable-decoder=vp6f \
    --enable-decoder=vp7 --enable-decoder=vp8 --enable-decoder=vp9 "

    # 音频
    FFMPEG_OPTIONS="$FFMPEG_OPTIONS --enable-decoder=aac* --enable-decoder=ac3* --enable-decoder=adpcm* --enable-decoder=alac* \
    --enable-decoder=amr* --enable-decoder=ape --enable-decoder=cook \
    --enable-decoder=dca --enable-decoder=dolby_e --enable-decoder=eac3* --enable-decoder=flac \
    --enable-decoder=mp1* --enable-decoder=mp2* --enable-decoder=mp3* --enable-decoder=opus \
    --enable-decoder=pcm* --enable-decoder=sonic \
    --enable-decoder=truehd --enable-decoder=tta --enable-decoder=vorbis --enable-decoder=wma* "
       
    # 字幕
    FFMPEG_OPTIONS="$FFMPEG_OPTIONS  --enable-decoder=ass --enable-decoder=ccaption --enable-decoder=dvbsub --enable-decoder=dvdsub \
         --enable-decoder=mpl2 --enable-decoder=movtext \
         --enable-decoder=pgssub --enable-decoder=srt --enable-decoder=ssa --enable-decoder=subrip \
         --enable-decoder=xsub --enable-decoder=webvtt "

    # filters
    FFMPEG_OPTIONS="$FFMPEG_OPTIONS  --disable-filters \
    --enable-filter=aformat --enable-filter=amix --enable-filter=anull --enable-filter=aresample \
    --enable-filter=areverse --enable-filter=asetrate --enable-filter=atempo --enable-filter=atrim \
    --enable-filter=bwdif --enable-filter=delogo \
    --enable-filter=equalizer --enable-filter=estdif \
    --enable-filter=firequalizer --enable-filter=format --enable-filter=fps \
    --enable-filter=hflip --enable-filter=hwdownload --enable-filter=hwmap --enable-filter=hwupload \
    --enable-filter=idet --enable-filter=lenscorrection --enable-filter=lut* --enable-filter=negate --enable-filter=null \
    --enable-filter=overlay \
    --enable-filter=palettegen --enable-filter=paletteuse --enable-filter=pan \
    --enable-filter=rotate \
    --enable-filter=scale --enable-filter=setpts --enable-filter=superequalizer \
    --enable-filter=transpose --enable-filter=trim \
    --enable-filter=vflip --enable-filter=volume \
    --enable-filter=w3fdif \
    --enable-filter=yadif \
    --enable-filter=avgblur_vulkan --enable-filter=blend_vulkan --enable-filter=bwdif_vulkan \
    --enable-filter=chromaber_vulkan --enable-filter=flip_vulkan --enable-filter=gblur_vulkan \
    --enable-filter=hflip_vulkan --enable-filter=nlmeans_vulkan --enable-filter=overlay_vulkan \
    --enable-filter=vflip_vulkan --enable-filter=xfade_vulkan "
}

run_build()
{
    LDFLAGS="$LDFLAGS -lc++ "

    local cpuFamily="x86_64"
    if [[ "$ARCH" != "x86_64" ]]; then
        cpuFamily="aarch64"
    fi

    if [ "$DEBUG_ENABLED" = "true" ]; then
        FFMPEG_OPTIONS="--enable-debug --disable-stripping --disable-optimizations"
    else
        FFMPEG_OPTIONS="--disable-debug --enable-stripping --enable-optimizations"
    fi
    if [[ "$PLATFORM" = "maccatalyst" || "$ARCH" = "x86_64" ]]; then
        FFMPEG_OPTIONS="$FFMPEG_OPTIONS --disable-neon --disable-asm"
    else
        FFMPEG_OPTIONS="$FFMPEG_OPTIONS --enable-neon --enable-asm"
    fi

    confugure

    #if [[ "$PLATFORM" = "macos" && $(uname -m) == $ARCH ]]; then
    #    FFMPEG_OPTIONS="$FFMPEG_OPTIONS  --enable-ffplay  \
    #            --enable-sdl2  \
    #            --enable-encoder=aac  \
    #            --enable-encoder=movtext  \
    #            --enable-encoder=mpeg4  \
    #            --enable-decoder=rawvideo  \
    #            --enable-filter=color  \
    #            --enable-filter=lut  \
    #            --enable-filter=negate  \
    #            --enable-filter=testsrc "
    #            echo "@@@@@@@@@@@@@@@@@@11111111111"
    #else
    #    FFMPEG_OPTIONS="$FFMPEG_OPTIONS --disable-programs"
    #fi
    FFMPEG_OPTIONS="$FFMPEG_OPTIONS --disable-programs"

    $ROOT_DIR/$sources_dir/configure --prefix=$SCRATCH/$ARCH \
        $FFMPEG_OPTIONS \
        --ignore-tests=TESTS \
        --disable-large-tests --enable-filter=subtitles \
        --enable-libbluray --enable-openssl --enable-libass --disable-iconv --enable-libplacebo  --enable-libdav1d \
        --enable-libfontconfig --enable-libharfbuzz --enable-vulkan --enable-lcms2  \
        --enable-libfribidi --enable-libfreetype --enable-libshaderc \
        --enable-decoder=libdav1d --enable-filter=ass --enable-filter=libplacebo \
        --target-os=darwin --arch=$cpuFamily \
        --enable-pic --disable-indev=avfoundation \
        --disable-outdev=audiotoolbox 
        #--enable-libsmbclient --enable-libsrt --enable-libzvbi
        #--enable-protocol=libsrt --enable-protocol=libsmbclient
        #--enable-decoder=libzvbi_teletext
            
    make -j5 -s
    make -j5 install -s
}

add_lipo_arguments()
{
    create_lipo_arguments "libavcodec" "libavcodec"
    create_lipo_arguments "libavfilter" "libavfilter"
    create_lipo_arguments "libavformat" "libavformat"
    create_lipo_arguments "libavutil" "libavutil"
    create_lipo_arguments "libavdevice" "libavdevice"
    create_lipo_arguments "libswscale" "libswscale"
    create_lipo_arguments "libswresample" "libswresample"
}

run_lipo()
{
    create_lipo "libavcodec" "libavcodec"
    local HEADERS="xvmc qsv vdpau dxva2 d3d11va"
    for HEADER in $HEADERS; do
        sed -i "3i\    exclude header \"$HEADER.h\"" $SCRATCH/Libavcodec.framework/Modules/module.modulemap
    done
    create_lipo "libavfilter" "libavfilter"
    create_lipo "libavformat" "libavformat"
    create_lipo "libavutil" "libavutil"
    local HEADERS="hwcontext_vulkan hwcontext_vdpau hwcontext_vaapi hwcontext_qsv hwcontext_opencl hwcontext_dxva2 hwcontext_d3d11va hwcontext_cuda"
    for HEADER in $HEADERS; do
        sed -i "3i\    exclude header \"$HEADER.h\"" $SCRATCH/Libavutil.framework/Modules/module.modulemap
    done
    create_lipo "libavdevice" "libavdevice"
    create_lipo "libswscale" "libswscale"
    create_lipo "libswresample" "libswresample"
}

add_xcframework_options()
{
    create_xcframework_options "libavcodec" "libavcodec"
    create_xcframework_options "libavfilter" "libavfilter"
    create_xcframework_options "libavformat" "libavformat"
    create_xcframework_options "libavutil" "libavutil"
    create_xcframework_options "libavdevice" "libavdevice"
    create_xcframework_options "libswscale" "libswscale"
    create_xcframework_options "libswresample" "libswresample"
}

run_xcframework()
{    
    create_xcframework "libavcodec" "libavcodec"
    create_xcframework "libavfilter" "libavfilter"
    create_xcframework "libavformat" "libavformat"
    create_xcframework "libavutil" "libavutil"
    create_xcframework "libavdevice" "libavdevice"
    create_xcframework "libswscale" "libswscale"
    create_xcframework "libswresample" "libswresample"
}

source config.sh



