BUILD:
1. ./init.sh  初始化环境
2. ./scripts/openssl.sh                     [ libcrypto libssl ]
3. 构建ass相关库(非必须)    
    1. ./scripts/png.sh                 
    2. ./scripts/unibreak.sh                用于处理Unicode字符断字 (非必须)
    3. ./scripts/fribidi.sh                 处理文字双向性
    4. ./scripts/freetype.sh                字体引擎库，用于处理和呈现字体
    5. ./scripts/harfbuzz.sh                用于文本渲染和字形布局
    6. ./scripts/fontconfig.sh              配置和定位字体 (非必须)
    7. ./scripts/ass.sh                     用于.ass字幕
4. 构建ffmpeg
    1. ./scripts/dav1d.sh                   AV1 视频解码器
    2. ./scripts/bluray.sh                  蓝光
    3. ./scripts/placebo.sh                 媒体播放和图像处理的开源库(mpv的一部分)
       1. ./scripts/lcms2.sh                开源的颜色管理系统
       2. ./scripts/dovi.sh                 杜比
       3. ./scripts/moltenVK.sh             用于在 macOS 和 iOS 上支持 Vulkan API 的开源项目 [libmoltenVK libSPIRVCross]
          1. ./scripts/shaderc.sh           用于将 GLSL或 HLSL 代码编译成 SPIR-V
    4. ./scripts/ffmpeg.sh
5. 构建mpv
    1. ./scripts/uchardet.sh                检测字幕字符编码(非必须)
    2. ./scripts/luajit.sh                  lua即时编译器(非必须)
    3. ./scripts/mpv.sh

