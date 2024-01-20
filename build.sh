#!/bin/bash
set -ex

#初始化环境
(./init.sh)
#构建openssl
(./scripts/openssl.sh)

#构建ass
(./scripts/png.sh)
(./scripts/unibreak.sh) 
(./scripts/fribidi.sh)
(./scripts/freetype.sh) 
(./scripts/harfbuzz.sh)
(./scripts/fontconfig.sh)
(./scripts/ass.sh)

#构建ffmpeg
(./scripts/dav1d.sh)
(./scripts/bluray.sh)
(./scripts/dovi.sh)
(./scripts/lcms2.sh)
(./scripts/shaderc.sh) 
(./scripts/moltenVK.sh)
(./scripts/placebo.sh)
(./scripts/ffmpeg.sh)

#构建mpv
(./scripts/uchardet.sh)
(./scripts/luajit.sh)
(./scripts/mpv.sh)
