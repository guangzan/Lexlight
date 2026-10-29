import { build } from 'esbuild';
import { createHash } from 'node:crypto';
import { copyFile, mkdir, readFile, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import * as themeExports from '@pierre/highlights/themes';

const root = fileURLToPath(new URL('../..', import.meta.url));
const packageJSON = JSON.parse(
  await readFile(`${root}/node_modules/@pierre/highlights/package.json`, 'utf8'),
);
const polyfills = await readFile(`${root}/scripts/highlights/polyfills.js`, 'utf8');
const output = `${root}/Sources/Lexlight/Resources/lexlight-highlights.js`;
const themesOutput = `${root}/Sources/Lexlight/Resources/themes.json`;
const manifestOutput = `${root}/Sources/Lexlight/Resources/resource-manifest.json`;
const vendorOutput = `${root}/Sources/Lexlight/Resources/Vendor/PierreHighlights`;

const banner = `/*! Lexlight ${packageJSON.version === '0.2.0' ? '1.0.0' : '1.0.0'} | @pierre/highlights v${packageJSON.version} | Apache-2.0
 * Generated file. Run pnpm run build:highlights instead of editing by hand.
 * Upstream: https://github.com/pierrecomputer/pierre
 */
${polyfills}`;

await build({
  absWorkingDir: root,
  entryPoints: ['scripts/highlights/entry.mjs'],
  outfile: output,
  bundle: true,
  format: 'iife',
  platform: 'browser',
  target: 'es2020',
  banner: { js: banner },
  logLevel: 'warning',
});

const themes = Object.entries(themeExports)
  .filter(([, value]) => value && typeof value === 'object' && value.name && value.style)
  .map(([key, value]) => normalizeTheme(toKebabCase(key), value))
  .filter(Boolean)
  .sort((left, right) => left.id.localeCompare(right.id));

await writeFile(themesOutput, `${JSON.stringify({ themes }, null, 2)}\n`);
await mkdir(vendorOutput, { recursive: true });
await copyFile(`${root}/node_modules/@pierre/highlights/LICENSE.md`, `${vendorOutput}/LICENSE.md`);
await copyFile(`${root}/node_modules/@pierre/highlights/NOTICE.md`, `${vendorOutput}/NOTICE.md`);

const source = await readFile(output);
const manifest = {
  lexlightVersion: '1.0.0',
  upstreamPackage: '@pierre/highlights',
  upstreamVersion: packageJSON.version,
  themeCount: themes.length,
  sha256: createHash('sha256').update(source).digest('hex'),
};
await writeFile(manifestOutput, `${JSON.stringify(manifest, null, 2)}\n`);
console.log(`Built ${themes.length} themes and ${source.byteLength} bytes of JavaScript.`);

function toKebabCase(value) {
  return value
    .replace(/([a-z0-9])([A-Z])/g, '$1-$2')
    .replace(/_/g, '-')
    .toLowerCase();
}

function normalizeTheme(id, theme) {
  const style = theme.style || {};
  const syntax = {};
  for (const [scope, raw] of Object.entries(style.syntax || {})) {
    const settings = typeof raw === 'string' ? { color: raw } : raw;
    if (!settings || typeof settings !== 'object') continue;
    const color = normalizeColor(settings.color);
    const background = normalizeColor(settings.background);
    const fontStyle = fontStyleBits(settings);
    if (!color && !background && fontStyle === 0) continue;
    syntax[scope] = {
      ...(color ? { color } : {}),
      ...(background ? { background } : {}),
      ...(fontStyle ? { font_style: fontStyle } : {}),
    };
  }
  const foreground = normalizeColor(style['editor.foreground'] ?? style.text ?? style.foreground);
  const background = normalizeColor(style['editor.background'] ?? style.background);
  if (!foreground && !background && Object.keys(syntax).length === 0) return null;
  return {
    id,
    name: theme.name || id,
    appearance: theme.appearance === 'light' ? 'light' : 'dark',
    ...(foreground ? { foreground } : {}),
    ...(background ? { background } : {}),
    syntax,
  };
}

function normalizeColor(value) {
  if (typeof value !== 'string') return undefined;
  const color = value.trim();
  return /^#[a-f0-9]{3,4}$/i.test(color) ||
    /^#[a-f0-9]{6}$/i.test(color) ||
    /^#[a-f0-9]{8}$/i.test(color)
    ? color
    : undefined;
}

function fontStyleBits(settings) {
  let bits = 0;
  const fontStyle = settings.font_style;
  if (typeof fontStyle === 'string' && fontStyle.includes('italic')) bits |= 1;
  const weight = settings.font_weight;
  if (
    (typeof weight === 'number' && weight >= 600) ||
    (typeof weight === 'string' && /^(bold|[6-9]00)$/.test(weight))
  ) {
    bits |= 2;
  }
  return bits;
}
