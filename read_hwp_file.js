const fs = require('fs');
const { HWPDocument } = require('node-hwp');

const filePath = '/Users/l2dogyu/Downloads/[서식6] 홈페이지제작 결과(완료) 보고서 양식.hwp';

async function readHWP() {
  try {
    console.log('HWP 파일 읽기 시작...\n');
    
    const buffer = fs.readFileSync(filePath);
    const hwpDoc = new HWPDocument(buffer);
    
    console.log('=== 파일 정보 ===');
    console.log('파일명:', filePath.split('/').pop());
    console.log('파일 크기:', buffer.length, 'bytes');
    
    const sections = hwpDoc.getSections();
    console.log('섹션 수:', sections.length);
    console.log('\n=== 문서 내용 ===\n');
    
    sections.forEach((section, idx) => {
      console.log(`--- Section ${idx + 1} ---`);
      const text = section.getText();
      console.log(text);
      console.log('');
    });
    
  } catch (error) {
    console.error('에러 발생:', error.message);
    console.error('\n상세 에러:', error);
  }
}

readHWP();

