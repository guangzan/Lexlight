import { createHash } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../..', import.meta.url));
const resourceRoot = `${root}/Sources/Lexlight/Resources`;
const packageJSON = JSON.parse(
  await readFile(`${root}/node_modules/@pierre/highlights/package.json`, 'utf8'),
);
const manifest = JSON.parse(await readFile(`${resourceRoot}/resource-manifest.json`, 'utf8'));
const themes = JSON.parse(await readFile(`${resourceRoot}/themes.json`, 'utf8')).themes;
const source = await readFile(`${resourceRoot}/lexlight-highlights.js`);
const javascript = source.toString('utf8');
const sha256 = createHash('sha256').update(source).digest('hex');

assert(packageJSON.version === '0.2.0', 'upstream version must be 0.2.0');
assert(manifest.upstreamVersion === packageJSON.version, 'manifest upstream version drift');
assert(manifest.themeCount === themes.length, 'manifest theme count drift');
assert(manifest.sha256 === sha256, 'generated JavaScript hash drift');
assert(javascript.includes('@pierre/highlights v0.2.0'), 'missing upstream banner');
assert(javascript.includes('globalThis.Lexlight'), 'missing Lexlight namespace');
assert(themes.length >= 70, `theme catalogue is unexpectedly small: ${themes.length}`);

console.log(`Verified ${themes.length} themes and ${source.byteLength} bytes of JavaScript.`);

function assert(condition, message) {
  if (!condition) {
    console.error(`verify:highlights failed: ${message}`);
    process.exitCode = 1;
    throw new Error(message);
  }
}
