# 09 — Repository initialisation and GitHub publication

Status: open
Blocked by: 08
Seams: `git status`, `git log`, remote branch, GitHub Actions run
Touchpoints: `.git/**`, `README.md`, repository settings

## What to build

Initialize Git, verify the full test and generation gates, create one commit per
completed task, create the public GitHub repository under the authenticated
account, push the repository, and confirm the default branch and CI status.

## Acceptance criteria

- [ ] No build artifacts, secrets, or node modules are tracked.
- [ ] Full local test and verification suite is green before push.
- [ ] GitHub remote points to the Lexlight repository and `main` is pushed.
- [ ] Default branch is `main` and CI has started or completed.
- [ ] Published README renders with correct English/Chinese switching.
