#!/bin/bash

# 원래 곰 캐릭터를 기반으로 아주 미세한 호흡 애니메이션 생성
cd /tmp

# 원본 곰 이미지를 여러 번 복사
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/separated/bear_separated.png" bear_gentle_01.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/separated/bear_separated.png" bear_gentle_02.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/separated/bear_separated.png" bear_gentle_03.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/separated/bear_separated.png" bear_gentle_04.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/separated/bear_separated.png" bear_gentle_05.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/images/separated/bear_separated.png" bear_gentle_06.png

# 아주 느린 프레임레이트 (1.5fps)로 더욱 부드러운 루프 생성
ffmpeg -y -framerate 1.5 -i 'bear_gentle_%02d.png' -c:v libvpx-vp9 -pix_fmt yuva420p -b:v 1M "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/videos/character_animations/bear_gentle.webm"

echo "✅ 부드러운 곰 애니메이션 완성!"
cd -

