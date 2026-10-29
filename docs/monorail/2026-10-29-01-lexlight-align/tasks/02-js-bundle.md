# 02 — Reproducible JavaScript bundle and registry data

Status: open
Blocked by: 01
Seams: `scripts/highlights/verify.mjs` generated-resource check; `Tests/LexlightTests/ResourceTests.swift` packaged-resource seam.
Touchpoints: `package.json`, `pnpm-lock.yaml`, `scripts/highlights/**`, `Sources/Lexlight/Resources/**`, `Vendor/**`

## What to build

Pin `@pierre/highlights@0.2.0` and esbuild, add the `Lexlight` JavaScript
namespace wrapper, generate the complete theme catalogue and language alias
data, and commit one auditable `lexlight-highlights.js` resource. Preserve
upstream LICENSE/NOTICE plus Lexlight attribution and add a verification script
for upstream version, language count, theme count, and generated banner.

## Acceptance criteria

- [ ] `pnpm run build:highlights` regenerates the committed bundle.
- [ ] `pnpm run verify:highlights` fails on drift or missing notices.
- [ ] Bundle exposes `globalThis.Lexlight` with the documented functions.
- [ ] Bundle contains all upstream languages and usable themes.
- [ ] No Node.js toolchain is required by Swift package consumers.
