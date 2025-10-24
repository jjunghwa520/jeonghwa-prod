import { Page } from '@playwright/test';
import { writeFileSync } from 'fs';
import path from 'path';
import { getRunArtifactsDir } from './paths';

export type OverflowItem = {
  selector: string;
  scrollWidth: number;
  clientWidth: number;
  marginLeft?: number;
  marginRight?: number;
  gap?: number;
  overBy: number; // scrollWidth - clientWidth
};

function cssPath(el: Element): string {
  // Simple CSS path for diagnostics
  const parts: string[] = [];
  let current: Element | null = el;
  while (current && parts.length < 8) {
    const name = current.tagName.toLowerCase();
    const id = (current as HTMLElement).id ? `#${(current as HTMLElement).id}` : '';
    const cls = (current as HTMLElement).className
      ? '.' + String((current as HTMLElement).className).trim().split(/\s+/).slice(0, 2).join('.')
      : '';
    parts.unshift(`${name}${id}${cls}`);
    current = current.parentElement;
  }
  return parts.join(' > ');
}

export async function inspectOverflow(page: Page) {
  return page.evaluate(() => {
    const doc = document.documentElement;
    const hasOverflow = doc.scrollWidth > doc.clientWidth;

    function pathFor(el: Element): string {
      // @ts-ignore
      return (window as any).__cssPath?.(el) || '';
    }

    const items: any[] = [];
    if (hasOverflow) {
      const all = Array.from(document.querySelectorAll<HTMLElement>('body *'));
      for (const el of all) {
        const sw = el.scrollWidth || 0;
        const cw = el.clientWidth || 0;
        const styles = getComputedStyle(el);
        const ml = parseFloat(styles.marginLeft || '0');
        const mr = parseFloat(styles.marginRight || '0');
        const gap = parseFloat((styles as any).gap || '0');
        const overBy = Math.max(0, sw - cw);
        if (overBy > 0) {
          // @ts-ignore
          const selector = (window as any).__cssPath?.(el) || '';
          items.push({ selector, scrollWidth: sw, clientWidth: cw, marginLeft: ml, marginRight: mr, gap, overBy });
        }
      }
      items.sort((a, b) => b.overBy - a.overBy);
    }

    return {
      hasOverflow,
      scrollWidth: doc.scrollWidth,
      clientWidth: doc.clientWidth,
      items: items.slice(0, 10)
    };
  });
}

export function saveOverflowReport(routeStem: string, data: any) {
  const dir = getRunArtifactsDir();
  const jsonPath = path.join(dir, `${routeStem}-overflow.json`);
  writeFileSync(jsonPath, JSON.stringify(data, null, 2), 'utf-8');
  // rudimentary CSV for quick view
  if (data?.items?.length) {
    const header = 'selector,scrollWidth,clientWidth,marginLeft,marginRight,gap,overBy\n';
    const rows = data.items
      .map((i: any) => [i.selector, i.scrollWidth, i.clientWidth, i.marginLeft, i.marginRight, i.gap, i.overBy]
        .map((v: any) => String(v).replace(/,/g, ';')).join(','))
      .join('\n');
    const csvPath = path.join(dir, `${routeStem}-overflow.csv`);
    writeFileSync(csvPath, header + rows, 'utf-8');
  }
  return jsonPath;
}




