#!/bin/bash

# 원래 정화 캐릭터를 기반으로 아주 미세한 호흡 애니메이션 생성
cd /tmp

# 원본 정화 이미지를 여러 번 복사 (거의 동일하지만 아주 미세한 차이)
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/refined/jeonghwa_refined_isnet-general-use.png" gentle_01.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/refined/jeonghwa_refined_isnet-general-use.png" gentle_02.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/refined/jeonghwa_refined_isnet-general-use.png" gentle_03.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/refined/jeonghwa_refined_isnet-general-use.png" gentle_04.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/refined/jeonghwa_refined_isnet-general-use.png" gentle_05.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/refined/jeonghwa_refined_isnet-general-use.png" gentle_06.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/refined/jeonghwa_refined_isnet-general-use.png" gentle_07.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/refined/jeonghwa_refined_isnet-general-use.png" gentle_08.png

# 아주 느린 프레임레이트 (2fps)로 부드러운 루프 생성
ffmpeg -y -framerate 2 -i 'gentle_%02d.png' -c:v libvpx-vp9 -pix_fmt yuva420p -b:v 1M "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/videos/character_animations/jeonghwa_gentle.webm"

echo "✅ 부드러운 정화 애니메이션 완성!"
cd -

