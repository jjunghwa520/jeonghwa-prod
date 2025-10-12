#!/usr/bin/env python3
"""
간단한 rembg 배경 제거 스크립트
"""

import os
import sys
from pathlib import Path

def remove_background_simple(input_path, output_path):
    """간단한 배경 제거"""
    try:
        from rembg import remove
        from PIL import Image
        
        print(f"🎯 배경 제거: {os.path.basename(input_path)}")
        
        # 입력 이미지 로드
        with open(input_path, 'rb') as input_file:
            input_data = input_file.read()
        
        # 배경 제거
        output_data = remove(input_data)
        
        # 결과 저장
        with open(output_path, 'wb') as output_file:
            output_file.write(output_data)
        
        # 결과 검증
        if os.path.exists(output_path) and os.path.getsize(output_path) > 0:
            file_size = os.path.getsize(output_path) / (1024 * 1024)
            print(f"✅ 성공: {os.path.basename(output_path)} ({file_size:.2f}MB)")
            return True
        else:
            print(f"❌ 실패: 파일 생성되지 않음")
            return False
            
    except Exception as e:
        print(f"❌ 예외: {str(e)}")
        return False

def main():
    """메인 실행"""
    print("🎯 rembg로 완전한 객체 분리!")
    
    # 프로젝트 루트 경로
    project_root = Path(__file__).parent.parent
    
    # 처리할 캐릭터들
    characters = [
        {
            'name': '정화 (환영)',
            'input': str(project_root / 'public/images/jeonghwa/gemini_nano/jeonghwa_gemini_welcome.png'),
            'output': str(project_root / 'public/images/separated/jeonghwa_separated.png')
        },
        {
            'name': '정화 (기본)',
            'input': str(project_root / 'public/images/jeonghwa/gemini_nano/jeonghwa_gemini_main.png'),
            'output': str(project_root / 'public/images/separated/jeonghwa_main_separated.png')
        },
        {
            'name': '곰 학생',
            'input': str(project_root / 'public/images/jeonghwa/safe/friendly_bear_educator.png'),
            'output': str(project_root / 'public/images/separated/bear_separated.png')
        },
        {
            'name': '토끼 학생',
            'input': str(project_root / 'public/images/jeonghwa/safe/caring_rabbit_storyteller.png'),
            'output': str(project_root / 'public/images/separated/rabbit_separated.png')
        }
    ]
    
    # 출력 디렉토리 생성
    output_dir = project_root / 'public/images/separated'
    output_dir.mkdir(exist_ok=True)
    
    success_count = 0
    total_count = len(characters)
    
    for char in characters:
        print("━" * 50)
        print(f"🎨 {char['name']} 처리")
        
        if os.path.exists(char['input']):
            if remove_background_simple(char['input'], char['output']):
                success_count += 1
        else:
            print(f"❌ 원본 파일 없음: {char['input']}")
    
    print("\n" + "=" * 50)
    print("🎉 rembg 객체 분리 완료!")
    print(f"✅ 성공: {success_count}/{total_count}")
    
    if success_count > 0:
        print("\n📁 분리된 객체들:")
        for file_path in output_dir.glob('*'):
            print(f"  - {file_path.name}")

if __name__ == "__main__":
    main()

