// Dropzone.js for bulk file upload
import Dropzone from "dropzone";
import "dropzone/dist/dropzone.css";

document.addEventListener('turbo:load', () => {
  const uploadForm = document.getElementById('bulk-upload-dropzone');
  
  if (uploadForm && !uploadForm.dropzone) {
    const courseIdInput = document.getElementById('dropzone_course_id');
    const kindSelect = document.getElementById('dropzone_kind');
    
    const dropzone = new Dropzone('#bulk-upload-dropzone', {
      url: '/admin/uploads',
      method: 'post',
      paramName: 'upload[files][]',
      uploadMultiple: true,
      parallelUploads: 5,
      maxFiles: 50,
      maxFilesize: 50, // MB
      acceptedFiles: 'image/*,video/*,.vtt,.m3u8,.ts,.txt',
      addRemoveLinks: true,
      dictDefaultMessage: '📁 여기에 파일을 끌어다 놓으세요<br>(또는 클릭하여 선택)',
      dictRemoveFile: '삭제',
      dictCancelUpload: '취소',
      
      init: function() {
        this.on('sending', function(file, xhr, formData) {
          const courseId = courseIdInput.value;
          const kind = kindSelect.value;
          
          if (!courseId || !kind) {
            alert('코스 ID와 종류를 먼저 선택해주세요!');
            this.removeFile(file);
            return false;
          }
          
          formData.append('course_id', courseId);
          formData.append('kind', kind);
          formData.append('authenticity_token', document.querySelector('[name="csrf-token"]').content);
        });
        
        this.on('success', function(file, response) {
          console.log('✅ 업로드 성공:', file.name);
        });
        
        this.on('error', function(file, errorMessage) {
          console.error('❌ 업로드 실패:', file.name, errorMessage);
          alert(`업로드 실패: ${file.name}\n${errorMessage}`);
        });
        
        this.on('queuecomplete', function() {
          alert('✨ 모든 파일 업로드 완료!');
          location.reload();
        });
      }
    });
  }
});

