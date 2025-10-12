구글 나노 바나나(Nano Banana) & Veo 동영상 생성 통합 가이드
개요
구글의 "나노 바나나(Nano Banana)"는 Gemini 2.5 Flash Image 모델의 별칭으로, Google DeepMind에서 개발한 최신 이미지 생성 및 편집 모델입니다. 또한 구글의 Veo 3는 최첨단 동영상 생성 모델로, 텍스트 프롬프트나 이미지로부터 고품질 8초 동영상을 네이티브 오디오와 함께 생성할 수 있습니다. 이 가이드는 홈페이지에 Vertex AI, 나노 바나나, Veo를 통합하여 다양한 이미지 및 동영상 콘텐츠를 생성할 수 있는 종합적인 시스템을 구축하는 방법을 설명합니다.

1. 나노 바나나(Nano Banana) 기본 정보
모델 정보
정식 명칭: Gemini 2.5 Flash Image (별칭: Nano Banana)
개발사: Google DeepMind
출시일: 2024년 8월 26일
특징: 세계 최고 평점의 이미지 편집 모델
주요 기능
텍스트-이미지 생성: 텍스트 설명으로 고품질 이미지 생성
이미지 편집: 기존 이미지에 텍스트 프롬프트로 요소 추가/제거/수정
다중 이미지 합성: 여러 이미지를 조합하여 새로운 장면 생성
반복적 개선: 대화형으로 이미지를 점진적으로 개선
고품질 텍스트 렌더링: 로고, 다이어그램, 포스터용 텍스트 포함 이미지 생성
워터마크 정책
모든 생성/편집된 이미지에 SynthID 디지털 워터마크 포함
Gemini 앱 무료 버전: 눈에 보이는 워터마크
모든 버전: 보이지 않는 SynthID 워터마크
1.2 Veo 동영상 생성 모델 정보
모델 정보
정식 명칭: Veo 3 (최신), Veo 2 (이전 버전)
개발사: Google DeepMind
특징: 최첨단 동영상 생성 모델, 네이티브 오디오 생성 지원
주요 기능
텍스트-동영상 생성: 텍스트 설명으로 고품질 동영상 생성
이미지-동영상 생성: 이미지를 시작 프레임으로 사용하여 동영상 생성
네이티브 오디오 생성: Veo 3에서 동영상과 함께 자동으로 오디오 생성
다양한 해상도: 720p, 1080p (Veo 3만 지원)
유연한 길이: 4-8초 동영상 생성 가능
지원 모델
Veo 3: veo-3.0-generate-001, veo-3.0-fast-generate-001
Veo 2: veo-2.0-generate-001, veo-2.0-generate-exp
기술 사양
기능	Veo 3	Veo 2
오디오 생성	✅ 네이티브 지원	❌ 무음만
해상도	720p, 1080p	720p
동영상 길이	4-8초	5-8초
프레임 레이트	24fps	24fps
입력 방식	텍스트, 이미지	텍스트, 이미지
2. API 접근 방법
2.1 Gemini API 사용 (나노 바나나 직접 접근)
javascript 
// JavaScript 예제
import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({
  apiKey: "YOUR_GEMINI_API_KEY"
});

async function generateImage(prompt) {
  const response = await ai.models.generateContent({
    model: "gemini-2.5-flash-image-preview",
    contents: prompt,
  });

  for (const part of response.candidates[0].content.parts) {
    if (part.inlineData) {
      const imageData = part.inlineData.data;
      const buffer = Buffer.from(imageData, "base64");
      return buffer;
    }
  }
}
python 
# Python 예제
from google import genai
from PIL import Image
from io import BytesIO

client = genai.Client()

def generate_image(prompt):
    response = client.models.generate_content(
        model="gemini-2.5-flash-image-preview",
        contents=[prompt],
    )
    
    for part in response.candidates[0].content.parts:
        if part.inline_data is not None:
            image = Image.open(BytesIO(part.inline_data.data))
            return image
2.2 Vertex AI 사용 (Imagen 모델)
python 
# Python - Vertex AI Imagen
from vertexai.preview.vision_models import ImageGenerationModel

def generate_with_imagen(prompt):
    generation_model = ImageGenerationModel.from_pretrained("imagen-4.0-generate-001")
    
    response = generation_model.generate_images(
        prompt=prompt,
        number_of_images=1,
        aspect_ratio="1:1",
        safety_filter_level="block_medium_and_above",
        person_generation="allow_adult"
    )
    
    return response.images[0]
2.3 Veo 동영상 생성 API
javascript 
// JavaScript - Veo 3 동영상 생성
import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({
  apiKey: "YOUR_GEMINI_API_KEY"
});

async function generateVideo(prompt, options = {}) {
  const {
    aspectRatio = "16:9",
    resolution = "720p",
    duration = 8,
    generateAudio = true
  } = options;

  // 동영상 생성 작업 시작
  let operation = await ai.models.generateVideos({
    model: "veo-3.0-generate-001",
    prompt: prompt,
    config: {
      aspectRatio: aspectRatio,
      resolution: resolution,
      durationSeconds: duration,
      generateAudio: generateAudio
    }
  });

  // 작업 완료까지 폴링
  while (!operation.done) {
    console.log("동영상 생성 중...");
    await new Promise((resolve) => setTimeout(resolve, 10000));
    operation = await ai.operations.getVideosOperation({ operation });
  }

  // 동영상 다운로드
  const video = operation.response.generatedVideos[0];
  return video;
}