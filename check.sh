#!/usr/bin/env bash
# Everything CI runs for this repo, in one place so the same checks can run
# before a push instead of after. CI calls this file, and so does
# .githooks/pre-push. Enable the hook once per clone:
#
#   git config core.hooksPath .githooks
#
# Runs on Linux and macOS. The zsh syntax check is skipped where zsh is absent.
set -euo pipefail
cd "$(dirname "$0")"

command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck is required: brew install shellcheck" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required: brew install jq" >&2; exit 1; }

echo "== shellcheck"
shellcheck -S warning check.sh install.sh handy/*.sh

echo "== syntax"
for f in check.sh install.sh handy/*.sh; do bash -n "$f"; done
if command -v zsh >/dev/null 2>&1; then
  zsh -n .zshrc
else
  echo "zsh not installed, skipping .zshrc syntax check"
fi

echo "== json"
jq empty handy/settings.fragment.json

echo "== no credentials tracked"
if git ls-files | grep -Ei '(^|/)(auth|credentials?)[^/]*\.json$|\.local$|\.env$|\.pem$'; then
  echo "credential-looking file is tracked" >&2
  exit 1
fi

echo "== install smoke test (throwaway HOME)"
smoke_home="$(mktemp -d)"
trap 'rm -rf "$smoke_home"' EXIT
HOME="$smoke_home" ./install.sh --no-brew >/dev/null
for f in .zshrc .gitconfig .gitignore_global .editorconfig .config/starship.toml .local/bin/.functions; do
  [[ -L "$smoke_home/$f" && -e "$smoke_home/$f" ]] || { echo "not linked or dangling: ~/$f" >&2; exit 1; }
done
[[ -f "$smoke_home/.gitconfig.local" ]] || { echo "missing ~/.gitconfig.local" >&2; exit 1; }
if HOME="$smoke_home" ./install.sh --no-brew 2>&1 | grep -q 'backed up'; then
  echo "second install run was not idempotent" >&2
  exit 1
fi

echo "== install rejects unknown options"
if ./install.sh --bogus 2>/dev/null; then
  echo "expected --bogus to fail" >&2
  exit 1
fi

echo "dotfiles: all checks passed"
