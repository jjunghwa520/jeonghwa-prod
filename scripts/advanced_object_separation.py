#!/usr/bin/env python3
"""
고급 객체 분리 스크립트
Python rembg 라이브러리를 사용한 완전한 배경 제거
"""

import os
import sys
from pathlib import Path
from PIL import Image
import requests

def install_and_import_rembg():
    """rembg 라이브러리 설치 및 임포트"""
    try:
        from rembg import remove, new_session
        print("✅ rembg 라이브러리 로드 완료")
        return remove, new_session
    except ImportError:
        print("📦 rembg 라이브러리 설치 중...")
        os.system("pip3 install rembg[gpu]")  # GPU 가속 버전
        try:
            from rembg import remove, new_session
            print("✅ rembg 라이브러리 설치 및 로드 완료")
            return remove, new_session
        except ImportError:
            print("❌ rembg 라이브러리 설치 실패")
            return None, None

def advanced_object_separation(input_path, output_path, model_name='u2net'):
    """고급 객체 분리 함수"""
    print(f"🎯 고급 객체 분리: {os.path.basename(input_path)}")
    print(f"🤖 모델: {model_name}")
    
    remove_func, new_session = install_and_import_rembg()
    if not remove_func:
        return False
    
    try:
        # 입력 이미지 로드
        with open(input_path, 'rb') as input_file:
            input_data = input_file.read()
        
        # AI 모델로 배경 제거
        if model_name != 'u2net':
            session = new_session(model_name)
            output_data = remove(input_data, session=session)
        else:
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
    """메인 실행 함수"""
    print("🎯 완전한 객체 분리 시작!")
    print("🤖 AI 기반 배경 제거 (rembg)")
    print("✨ 다양한 모델로 최적 결과 찾기")
    
    # 프로젝트 루트 경로
    project_root = Path(__file__).parent.parent
    
    # 처리할 캐릭터들
    characters = [
        {
            'name': '정화 (환영)',
            'input': project_root / 'public/images/jeonghwa/gemini_nano/jeonghwa_gemini_welcome.png',
            'output': project_root / 'public/images/separated/jeonghwa_separated.png'
        },
        {
            'name': '정화 (기본)',
            'input': project_root / 'public/images/jeonghwa/gemini_nano/jeonghwa_gemini_main.png',
            'output': project_root / 'public/images/separated/jeonghwa_main_separated.png'
        },
        {
            'name': '곰 학생',
            'input': project_root / 'public/images/jeonghwa/safe/friendly_bear_educator.png',
            'output': project_root / 'public/images/separated/bear_separated.png'
        },
        {
            'name': '토끼 학생',
            'input': project_root / 'public/images/jeonghwa/safe/caring_rabbit_storyteller.png',
            'output': project_root / 'public/images/separated/rabbit_separated.png'
        }
    ]
    
    # 출력 디렉토리 생성
    output_dir = project_root / 'public/images/separated'
    output_dir.mkdir(exist_ok=True)
    
    # 사용할 AI 모델들 (정확도 순)
    models = ['u2net', 'u2net_human_seg', 'silueta', 'isnet-general-use']
    
    success_count = 0
    total_count = len(characters)
    
    for char in characters:
        print("━" * 70)
        print(f"🎨 {char['name']} 객체 분리")
        
        if not char['input'].exists():
            print(f"❌ 원본 파일 없음: {char['input']}")
            continue
        
        # 여러 모델로 시도
        success = False
        for model in models:
            print(f"🔄 {model} 모델 시도...")
            
            temp_output = str(char['output']).replace('.png', f'_{model}.png')
            if advanced_object_separation(str(char['input']), temp_output, model):
                # 가장 좋은 결과를 최종 파일로 복사
                os.rename(temp_output, str(char['output']))
                success = True
                break
        
        if success:
            success_count += 1
        else:
            print(f"❌ {char['name']} 모든 모델 실패")
    
    print("\n" + "=" * 70)
    print("🎉 완전한 객체 분리 완료!")
    print(f"✅ 성공: {success_count}/{total_count}")
    print(f"❌ 실패: {total_count - success_count}/{total_count}")
    
    if success_count > 0:
        print("\n📁 분리된 객체들:")
        for file_path in output_dir.glob('*'):
            print(f"  - {file_path.name}")
        
        print("\n🤖 사용된 AI 모델들:")
        for model in models:
            print(f"  - {model}: 고급 객체 분리 특화")
        
        print("\n💡 사용법:")
        print("  /images/separated/ 경로의 완전 분리된 객체들 사용")

if __name__ == "__main__":
    main()

