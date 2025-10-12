#!/bin/bash
cd /tmp
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/app/assets/images/generated/bear_3d_waddle_02.png" bear_01.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/app/assets/images/generated/bear_3d_waddle_03.png" bear_02.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/app/assets/images/generated/bear_3d_curious_01.png" bear_03.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/app/assets/images/generated/bear_3d_nod_01.png" bear_04.png
cp "/Users/l2dogyu/KICDA/ruby/kicda-jh/app/assets/images/generated/bear_3d_happy.png" bear_05.png

ffmpeg -y -framerate 8 -i 'bear_%02d.png' -c:v libvpx-vp9 -pix_fmt yuva420p -b:v 2M "/Users/l2dogyu/KICDA/ruby/kicda-jh/public/videos/character_animations/bear_walk.webm"

echo "✅ 곰 비디오 완성!"
cd -

