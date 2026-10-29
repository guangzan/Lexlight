# 02 — Reproducible JavaScript bundle and registry data

Status: done
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

- [x] `pnpm run build:highlights` regenerates the committed bundle.
- [x] `pnpm run verify:highlights` fails on drift or missing notices.
- [x] Bundle exposes `globalThis.Lexlight` with the documented functions.
- [x] Bundle contains all upstream languages and usable themes.
- [x] No Node.js toolchain is required by Swift package consumers.

## Comments

Run 2026-10-29: start — 38e3836
done — pending task commit
- seams used: `scripts/highlights/verify.mjs`, `Tests/LexlightTests/ResourceTests.swift`
- typecheck: green
- relevant tests: green (`pnpm run verify:highlights`, `swift test`)
- acceptance criteria: met
