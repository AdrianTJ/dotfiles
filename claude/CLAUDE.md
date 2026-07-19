# Global conventions (all repos)

## Git

- Branch names describe the actual feature or evaluation: `add-rate-limiting`,
  `eval-bass-optimizer`, `fix-zsh-read-prompt`. No generic names, no tool prefixes.
- Never commit or push directly to `main`/`master` — branch first.
- Commits from joint work are authored as me — Adrian TJ
  <adrian.tame.jacobo@gmail.com> — with Claude credited as a trailer:

  ```
  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

- Pull requests: no attribution or "Generated with ..." block in the body.
  Describe the change; that's it.

## Verification

Before committing non-trivial changes, run the project's own checks. If the
repo doesn't say, defaults by language:

| Language | Check |
| :--- | :--- |
| Python | `ruff check . && pytest` |
| Go | `go vet ./... && go test ./...` |
| Rust | `cargo clippy && cargo test` |
| TypeScript | `tsc --noEmit` + the repo's test script |
