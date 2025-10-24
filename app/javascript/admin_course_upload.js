// 파일 업로드 관리
let selectedFiles = [];

function initFileUpload() {
  const dropzone = document.getElementById('file-upload-area');
  const fileInput = document.getElementById('file-input');
  const fileList = document.getElementById('file-list');
  const fileItems = document.getElementById('file-items');

  if (!dropzone || !fileInput) return;

  // 드래그 앤 드롭 이벤트
  dropzone.addEventListener('dragover', (e) => {
    e.preventDefault();
    dropzone.classList.add('dragover');
  });

  dropzone.addEventListener('dragleave', () => {
    dropzone.classList.remove('dragover');
  });

  dropzone.addEventListener('drop', (e) => {
    e.preventDefault();
    dropzone.classList.remove('dragover');
    
    const files = Array.from(e.dataTransfer.files);
    handleFiles(files);
  });

  // 파일 선택 이벤트
  fileInput.addEventListener('change', (e) => {
    const files = Array.from(e.target.files);
    handleFiles(files);
  });

  function handleFiles(files) {
    selectedFiles = [...selectedFiles, ...files];
    validateAndSortFiles();
    displayFiles();
  }

  function validateAndSortFiles() {
    const contentType = getSelectedContentType();
    
    // 파일명으로 정렬
    selectedFiles.sort((a, b) => {
      const aMatch = a.name.match(/page_(\d+)/);
      const bMatch = b.name.match(/page_(\d+)/);
      
      if (aMatch && bMatch) {
        return parseInt(aMatch[1]) - parseInt(bMatch[1]);
      }
      return a.name.localeCompare(b.name);
    });

    // 파일 검증
    selectedFiles.forEach(file => {
      file.valid = validateFile(file, contentType);
    });
  }

  function validateFile(file, contentType) {
    const validations = {
      errors: [],
      warnings: []
    };

    // 파일 형식 검증
    const ext = file.name.split('.').pop().toLowerCase();
    
    if (contentType === 'ebook') {
      const validExts = ['jpg', 'jpeg', 'png', 'txt'];
      if (!validExts.includes(ext)) {
        validations.errors.push('지원하지 않는 형식');
      }

      // 파일명 형식 검증
      if (['jpg', 'jpeg', 'png', 'txt'].includes(ext)) {
        if (!/^page_\d{3,4}\.(jpg|jpeg|png|txt)$/i.test(file.name)) {
          validations.errors.push('파일명 형식 오류 (예: page_001.jpg)');
        }
      }

      // 크기 검증
      const maxSize = ext === 'txt' ? 100 * 1024 : 10 * 1024 * 1024; // 100KB or 10MB
      if (file.size > maxSize) {
        validations.errors.push(`파일 크기 초과 (최대 ${formatFileSize(maxSize)})`);
      }
    } else if (contentType === 'video') {
      const validExts = ['mp4', 'webm', 'm3u8', 'vtt', 'srt'];
      if (!validExts.includes(ext)) {
        validations.errors.push('지원하지 않는 형식');
      }

      // 크기 검증
      const maxSize = 500 * 1024 * 1024; // 500MB
      if (file.size > maxSize) {
        validations.errors.push(`파일 크기 초과 (최대 ${formatFileSize(maxSize)})`);
      }
    }

    // 중복 검증
    const duplicates = selectedFiles.filter(f => f !== file && f.name === file.name);
    if (duplicates.length > 0) {
      validations.warnings.push('중복 파일명');
    }

    return {
      isValid: validations.errors.length === 0,
      errors: validations.errors,
      warnings: validations.warnings
    };
  }

  function displayFiles() {
    if (selectedFiles.length === 0) {
      fileList.style.display = 'none';
      return;
    }

    fileList.style.display = 'block';
    fileItems.innerHTML = '';

    selectedFiles.forEach((file, index) => {
      const item = document.createElement('div');
      item.className = `list-group-item file-item ${file.valid?.isValid ? 'valid' : 'invalid'}`;
      
      const validIcon = file.valid?.isValid ? '✓' : '⚠';
      const validClass = file.valid?.isValid ? 'text-success' : 'text-danger';
      
      let errorText = '';
      if (file.valid && !file.valid.isValid) {
        errorText = `<small class="text-danger d-block">${file.valid.errors.join(', ')}</small>`;
      }
      if (file.valid && file.valid.warnings.length > 0) {
        errorText += `<small class="text-warning d-block">${file.valid.warnings.join(', ')}</small>`;
      }

      item.innerHTML = `
        <div class="d-flex justify-content-between align-items-start">
          <div class="flex-grow-1">
            <span class="${validClass} me-2">${validIcon}</span>
            <strong>${file.name}</strong>
            <small class="text-muted ms-2">(${formatFileSize(file.size)})</small>
            ${errorText}
          </div>
          <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeFile(${index})">
            🗑️
          </button>
        </div>
      `;
      
      fileItems.appendChild(item);
    });

    // 요약 정보 표시
    const summary = document.createElement('div');
    summary.className = 'mt-3 p-3 bg-light rounded';
    const validCount = selectedFiles.filter(f => f.valid?.isValid).length;
    const totalCount = selectedFiles.length;
    
    summary.innerHTML = `
      <strong>파일 요약:</strong>
      총 ${totalCount}개 파일 |
      <span class="text-success">✓ ${validCount}개 유효</span> |
      <span class="text-danger">⚠ ${totalCount - validCount}개 문제</span>
    `;
    
    fileItems.appendChild(summary);
  }

  function getSelectedContentType() {
    const selected = document.querySelector('input[name="content_type_selection"]:checked');
    return selected ? selected.value : 'ebook';
  }

  // 글로벌 함수로 노출
  window.removeFile = function(index) {
    selectedFiles.splice(index, 1);
    displayFiles();
  };

  function formatFileSize(bytes) {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  }
}

// 난이도 선택 개선
document.addEventListener('DOMContentLoaded', function() {
  const difficultyInputs = document.querySelectorAll('.difficulty-selector input[type="radio"]');
  
  difficultyInputs.forEach(input => {
    input.addEventListener('change', function() {
      const level = parseInt(this.value);
      const labels = document.querySelectorAll('.difficulty-selector label');
      
      labels.forEach((label, index) => {
        if (index < level) {
          label.style.opacity = '1';
        } else {
          label.style.opacity = '0.3';
        }
      });
    });
  });

  // 신규 작가 등록
  const saveAuthorBtn = document.getElementById('save-new-author');
  if (saveAuthorBtn) {
    saveAuthorBtn.addEventListener('click', async function() {
      const name = document.getElementById('new-author-name').value;
      const role = document.getElementById('new-author-role').value;
      const bio = document.getElementById('new-author-bio').value;

      if (!name) {
        alert('이름을 입력하세요');
        return;
      }

      try {
        const response = await fetch('/admin/authors', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
          },
          body: JSON.stringify({
            author: { name, role, bio, active: true }
          })
        });

        if (response.ok) {
          const data = await response.json();
          
          // 해당 역할의 select에 추가
          const selectId = `course_${role}_id`;
          const select = document.querySelector(`select[name="course[${role}_id]"]`);
          if (select) {
            const option = new Option(data.name, data.id, true, true);
            select.add(option);
          }

          // 모달 닫기
          const modal = bootstrap.Modal.getInstance(document.getElementById('newAuthorModal'));
          modal.hide();

          // 폼 초기화
          document.getElementById('new-author-name').value = '';
          document.getElementById('new-author-bio').value = '';
        } else {
          alert('작가 등록에 실패했습니다');
        }
      } catch (error) {
        console.error('Error:', error);
        alert('오류가 발생했습니다');
      }
    });
  }
});

// Export
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { initFileUpload };
}

