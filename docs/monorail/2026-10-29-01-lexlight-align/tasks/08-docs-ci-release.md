# 08 — Documentation, CI, and release metadata

Status: open
Blocked by: 02, 03, 04, 05, 06, 07
Seams: CI workflow commands; DocC build; `scripts/highlights/verify.mjs`; README language links.
Touchpoints: `.github/workflows/**`, `README.md`, `README.zh-CN.md`, `Sources/Lexlight/Lexlight.docc/**`, `LICENSE`, `NOTICE.md`, `Vendor/**`, `Package.swift`

## What to build

Write the English-first README and Chinese translation with language switching,
installation, native/Web examples, theme/language notes, error/cancellation
semantics, engine fallback, and licence attribution. Add DocC API docs, a
contribution-friendly NOTICE, and GitHub Actions for macOS and iOS builds,
tests, formatting/lint, DocC, resource drift, and tag/version consistency.

## Acceptance criteria

- [ ] README and README.zh-CN.md link to each other at the top.
- [ ] DocC builds without warnings.
- [ ] CI covers macOS tests, iOS simulator tests, formatting/lint, DocC, and bundle drift.
- [ ] Licence and upstream notices ship in source and package resources.
- [ ] Tag/version validation checks `Package.swift`, Swift version constant, and Git tag.
