---
description: Detect the project's stack and run its tests, linter, and typechecker
---

Verify the current project. Report results; fix nothing unless I ask.

1. **Find the project's own truth first.** Check, in order: CLAUDE.md/AGENTS.md,
   Makefile/justfile targets, package.json scripts, CI workflows
   (.github/workflows). If the repo defines check/test/lint commands, use
   exactly those and skip the defaults below.
2. **Otherwise, detect the stack and run:**
   - `pyproject.toml` / `*.py` → `ruff check .` then `pytest` (use `uv run` if uv.lock exists)
   - `go.mod` → `go vet ./...` then `go test ./...`
   - `Cargo.toml` → `cargo clippy -- -D warnings` then `cargo test`
   - `tsconfig.json` / `package.json` → `tsc --noEmit` then the test script if one exists
   - Mixed repo → run each detected stack.
3. **Report** a short pass/fail summary per check. On failure, show the
   relevant error output (not the full log) and where it points — but do not
   start fixing.
