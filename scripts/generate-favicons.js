#!/usr/bin/env node
/**
 * generate-favicons.js
 *
 * 单源生成站点 favicon 全套资源。
 *
 * 源 SVG:   ../design-system/v2/logo/logo.svg
 * 输出:     blog/static/{favicon.ico, favicon-16x16.png, favicon-32x32.png, apple-touch-icon.png}
 * 工具链:   sharp（SVG→PNG）+ png-to-ico（多帧 ICO 合成）
 *
 * 幂等性:   重复执行产出字节级一致的输出（sharp/png-to-ico 在固定输入下确定性输出）。
 *           如果 sharp 版本变化，PNG 字节可能变（属预期，重新提交即可）。
 *
 * 由变更:   add-blog-favicon-branding (2026-05-02)
 * 关联 spec: openspec/specs/blog-discoverability/spec.md
 *           "品牌 favicon 资源 MUST 替换 Blowfish 主题默认图标"
 *           "favicon 资源 MUST 由单源生成脚本可重复产出"
 *
 * 用法:     cd blog && node scripts/generate-favicons.js
 *           或      cd blog && npm run favicons
 *
 * fallback (B 路径):
 *   若 16/32 直缩 logo.svg 在小尺寸辨识度判定不通过，
 *   将 SOURCE_SMALL 改为 design-system/v2/logo/simple-mark.svg 即可（仅影响 16/32/ICO）。
 */

const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const pngToIco = require('png-to-ico');

const ROOT = path.resolve(__dirname, '..');
const STATIC_DIR = path.join(ROOT, 'static');
const SOURCE_LARGE = path.resolve(ROOT, '../design-system/v2/logo/logo.svg');
// 小尺寸源（A 方案与 SOURCE_LARGE 同源；B 方案改指 simple-mark.svg）
const SOURCE_SMALL = SOURCE_LARGE;

async function renderPng(srcSvg, size, outFile) {
  await sharp(srcSvg, { density: 384 })
    .resize(size, size, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .png({ compressionLevel: 9, adaptiveFiltering: true })
    .toFile(outFile);
  console.log(`  ✓ ${path.relative(ROOT, outFile)} (${size}×${size})`);
}

async function main() {
  if (!fs.existsSync(SOURCE_LARGE)) {
    console.error(`✗ 找不到源 SVG: ${SOURCE_LARGE}`);
    process.exit(1);
  }
  fs.mkdirSync(STATIC_DIR, { recursive: true });

  console.log(`源（大尺寸）: ${path.relative(ROOT, SOURCE_LARGE)}`);
  console.log(`源（小尺寸）: ${path.relative(ROOT, SOURCE_SMALL)}`);
  console.log(`输出: ${path.relative(ROOT, STATIC_DIR)}/`);
  console.log();

  // 1. 大尺寸 PNG（直接交付）
  await renderPng(SOURCE_LARGE, 180, path.join(STATIC_DIR, 'apple-touch-icon.png'));

  // 2. 小尺寸 PNG（直接交付）
  await renderPng(SOURCE_SMALL, 16, path.join(STATIC_DIR, 'favicon-16x16.png'));
  await renderPng(SOURCE_SMALL, 32, path.join(STATIC_DIR, 'favicon-32x32.png'));

  // 3. 临时 48 PNG（仅用于 ICO 合成，不交付）
  const tmp48 = path.join(STATIC_DIR, '.favicon-48.tmp.png');
  await renderPng(SOURCE_SMALL, 48, tmp48);

  // 4. ICO 多帧合成（16 + 32 + 48）
  const icoBuf = await pngToIco([
    path.join(STATIC_DIR, 'favicon-16x16.png'),
    path.join(STATIC_DIR, 'favicon-32x32.png'),
    tmp48,
  ]);
  const icoPath = path.join(STATIC_DIR, 'favicon.ico');
  fs.writeFileSync(icoPath, icoBuf);
  console.log(`  ✓ ${path.relative(ROOT, icoPath)} (16+32+48 多帧)`);

  // 5. 清理临时文件
  fs.unlinkSync(tmp48);

  console.log('\n完成。验证幂等性: shasum -a 256 static/favicon* static/apple-touch-icon.png');
}

main().catch((err) => {
  console.error('✗ 生成失败:', err);
  process.exit(1);
});
