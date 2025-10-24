import { test, expect } from '@playwright/test';
import { adminLogin } from '../utils/adminLogin';
import { attachErrorCollector } from '../utils/errorCollector';
import path from 'path';
import { writeFileSync } from 'fs';

test.describe('관리자 리그레션 - 업로드/리뷰/사용자 역할', () => {
  test.beforeEach(async ({ page }) => {
    if (!process.env.ADMIN_EMAIL || !process.env.ADMIN_PASSWORD) {
      test.skip(true, 'ADMIN_EMAIL/ADMIN_PASSWORD not set');
    }
  });
  test('업로드 → 되돌림', async ({ page }) => {
    const collector = attachErrorCollector(page);
    await adminLogin(page);
    await page.goto('/admin/uploads/new');
    const fileInput = page.locator('input[type="file"]');
    const tmpPath = path.resolve(__dirname, '../tmp-upload.txt');
    writeFileSync(tmpPath, 'temporary upload file');
    await fileInput.setInputFiles(tmpPath);
    const submit = page.getByRole('button', { name: /업로드|upload|create|저장/i }).first();
    await submit.click();
    await page.waitForLoadState('networkidle');
    // 상세 반영 확인 (플레이스홀더, 성공 플래시 등)
    await expect(page.locator('text=/성공|완료|created|uploaded/i')).toBeVisible({ timeout: 5000 });
    // 되돌림
    const backOrDelete = page.getByRole('button', { name: /삭제|되돌림|revert|rollback|cancel/i }).first();
    if (await backOrDelete.isVisible().catch(() => false)) {
      await backOrDelete.click();
      await page.waitForLoadState('networkidle');
    }
    collector.save('admin-upload');
  });

  test('리뷰 active 토글/삭제(테스트 데이터)', async ({ page }) => {
    const collector = attachErrorCollector(page);
    await adminLogin(page);
    await page.goto('/admin/reviews');
    const firstRow = page.locator('table tbody tr').first();
    if (await firstRow.count()) {
      const toggle = firstRow.getByRole('button', { name: /active|활성|비활성/i }).first();
      if (await toggle.isVisible().catch(() => false)) {
        await toggle.click();
      }
      const del = firstRow.getByRole('button', { name: /삭제|delete|remove/i }).first();
      if (await del.isVisible().catch(() => false)) {
        await del.click();
        // confirm dialog 자동 허용 X: 테스트 프레임워크에서 기본 허용 안 하므로 폴백
      }
      await page.waitForTimeout(500);
    }
    collector.save('admin-reviews');
  });

  test('사용자 역할 토글 후 원복', async ({ page }) => {
    const collector = attachErrorCollector(page);
    await adminLogin(page);
    await page.goto('/admin/users');
    const firstRow = page.locator('table tbody tr').first();
    if (await firstRow.count()) {
      const roleBtn = firstRow.getByRole('button', { name: /역할|role|권한|권한변경/i }).first();
      if (await roleBtn.isVisible().catch(() => false)) {
        await roleBtn.click();
        await page.waitForTimeout(400);
        // 원복 (가능한 경우 동일 버튼 재클릭)
        await roleBtn.click();
      }
    }
    collector.save('admin-users');
  });
});


