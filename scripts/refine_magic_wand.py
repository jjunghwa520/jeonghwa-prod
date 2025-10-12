#!/usr/bin/env python3
"""
마법봉 주변 정밀 처리를 위한 rembg 고급 모델 테스트
"""

import os
from pathlib import Path

def test_rembg_models(input_path, output_dir):
    """다양한 rembg 모델로 테스트"""
    try:
        from rembg import remove, new_session
        
        print(f"🎯 마법봉 주변 정밀 처리: {os.path.basename(input_path)}")
        
        # 사용 가능한 고급 모델들 (정밀도 순)
        models = [
            'u2net',           # 기본 (이미 사용)
            'u2net_human_seg', # 인물 특화
            'isnet-general-use', # 일반 용도 고정밀
            'silueta',         # 실루엣 특화
            'u2netp'           # 경량화 버전
        ]
        
        results = []
        
        for model_name in models:
            try:
                print(f"🔄 {model_name} 모델 테스트...")
                
                # 입력 이미지 로드
                with open(input_path, 'rb') as input_file:
                    input_data = input_file.read()
                
                # 모델별 세션 생성
                if model_name == 'u2net':
                    output_data = remove(input_data)
                else:
                    session = new_session(model_name)
                    output_data = remove(input_data, session=session)
                
                # 결과 저장
                output_path = output_dir / f"jeonghwa_refined_{model_name}.png"
                with open(output_path, 'wb') as output_file:
                    output_file.write(output_data)
                
                if os.path.exists(output_path) and os.path.getsize(output_path) > 0:
                    file_size = os.path.getsize(output_path) / (1024 * 1024)
                    print(f"✅ {model_name}: {output_path.name} ({file_size:.2f}MB)")
                    results.append({
                        'model': model_name,
                        'file': output_path.name,
                        'size': file_size
                    })
                else:
                    print(f"❌ {model_name}: 실패")
                    
            except Exception as e:
                print(f"❌ {model_name}: {str(e)}")
        
        return results
        
    except Exception as e:
        print(f"❌ rembg 로드 실패: {str(e)}")
        return []

def enhance_magic_wand_area(input_path, output_path):
    """마법봉 영역 특별 처리"""
    try:
        from PIL import Image, ImageFilter, ImageEnhance
        
        print(f"✨ 마법봉 영역 특별 처리: {os.path.basename(input_path)}")
        
        # 이미지 로드
        img = Image.open(input_path).convert("RGBA")
        
        # 알파 채널 추출
        alpha = img.split()[-1]
        
        # 알파 채널 정제 (가장자리 부드럽게)
        alpha = alpha.filter(ImageFilter.GaussianBlur(radius=0.5))
        
        # 대비 강화로 경계 선명하게
        enhancer = ImageEnhance.Contrast(alpha)
        alpha = enhancer.enhance(1.2)
        
        # 정제된 알파 채널 적용
        img.putalpha(alpha)
        
        # 결과 저장
        img.save(output_path, "PNG")
        
        file_size = os.path.getsize(output_path) / (1024 * 1024)
        print(f"✅ 마법봉 정제 완료: {os.path.basename(output_path)} ({file_size:.2f}MB)")
        return True
        
    except Exception as e:
        print(f"❌ 마법봉 정제 실패: {str(e)}")
        return False

def main():
    """메인 실행"""
    print("✨ 정화 캐릭터 마법봉 주변 정밀 처리!")
    print("🤖 다양한 rembg 모델 테스트")
    
    # 프로젝트 루트 경로
    project_root = Path(__file__).parent.parent
    
    # 입력 파일
    input_file = project_root / 'public/images/jeonghwa/gemini_nano/jeonghwa_gemini_welcome.png'
    
    # 출력 디렉토리
    output_dir = project_root / 'public/images/refined'
    output_dir.mkdir(exist_ok=True)
    
    if not input_file.exists():
        print(f"❌ 입력 파일 없음: {input_file}")
        return
    
    # 1단계: 다양한 모델로 테스트
    print("━" * 60)
    print("🔬 1단계: 다양한 rembg 모델 테스트")
    results = test_rembg_models(str(input_file), output_dir)
    
    # 2단계: 가장 좋은 결과에 추가 정제 적용
    if results:
        print("\n━" * 60)
        print("✨ 2단계: 마법봉 영역 특별 정제")
        
        # 가장 큰 파일 (일반적으로 가장 디테일이 보존된 것)
        best_result = max(results, key=lambda x: x['size'])
        best_file = output_dir / best_result['file']
        
        refined_output = output_dir / 'jeonghwa_magic_wand_refined.png'
        enhance_magic_wand_area(str(best_file), str(refined_output))
    
    print("\n" + "=" * 60)
    print("🎉 정화 캐릭터 마법봉 정밀 처리 완료!")
    
    if results:
        print("\n📁 생성된 정제 버전들:")
        for file_path in sorted(output_dir.glob('*')):
            print(f"  - {file_path.name}")
        
        print("\n💡 추천 사용 순서:")
        print("  1. jeonghwa_refined_isnet-general-use.png (가장 정밀)")
        print("  2. jeonghwa_magic_wand_refined.png (마법봉 특별 처리)")
        print("  3. jeonghwa_refined_u2net_human_seg.png (인물 특화)")

if __name__ == "__main__":
    main()

