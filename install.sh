#!/usr/bin/env bash
#
# install.sh — set up these dotfiles on a fresh machine.
#
#   ./install.sh            # install deps + symlink everything
#   ./install.sh --no-brew  # symlink only, skip Homebrew/package install
#   ./install.sh --help
#
# Safe to re-run: existing real files are backed up to <file>.bak once, and
# symlinks that already point where we want are left alone.

set -euo pipefail

# Resolve the directory this script lives in (the repo root), even via symlink.
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WITH_BREW=1
for arg in "$@"; do
    case "$arg" in
        --no-brew) WITH_BREW=0 ;;
        -h|--help)
            sed -n '3,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) printf 'Unknown option: %s\n' "$arg" >&2; exit 2 ;;
    esac
done

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
info()  { printf '  \033[36m→\033[0m %s\n' "$*"; }
ok()    { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn()  { printf '  \033[33m!\033[0m %s\n' "$*" >&2; }

# ---------------------------------------------------------------------------
# 1. Homebrew + packages
# ---------------------------------------------------------------------------
if [[ "$WITH_BREW" -eq 1 ]]; then
    bold "Installing packages"
    if ! command -v brew >/dev/null 2>&1; then
        warn "Homebrew not found."
        if [[ "$(uname -s)" == "Darwin" ]]; then
            info "Installing Homebrew…"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Make brew available for the rest of this run (Apple Silicon path).
            [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            warn "Not macOS — install Homebrew manually, then re-run, or use --no-brew."
        fi
    fi

    if command -v brew >/dev/null 2>&1; then
        info "brew bundle (from Brewfile)…"
        brew bundle --file="$DOTFILES/Brewfile"
        ok "Packages installed"
    else
        warn "Skipping package install (no brew)."
    fi
else
    bold "Skipping package install (--no-brew)"
fi

# ---------------------------------------------------------------------------
# 2. Symlinks
# ---------------------------------------------------------------------------
bold "Linking dotfiles"

# Ghostty config path differs by OS.
if [[ "$(uname -s)" == "Darwin" ]]; then
    GHOSTTY_DEST="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
else
    GHOSTTY_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
fi

# source -> destination pairs
link() {
    local src="$DOTFILES/$1" dest="$2"
    if [[ ! -e "$src" ]]; then warn "missing source: $1"; return; fi
    mkdir -p "$(dirname "$dest")"

    # Already linked correctly?
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        ok "$dest (already linked)"
        return
    fi
    # Back up a real file/dir (once) before replacing it.
    if [[ -e "$dest" && ! -L "$dest" ]]; then
        mv "$dest" "$dest.bak"
        warn "backed up existing $dest -> $dest.bak"
    fi
    ln -sfn "$src" "$dest"
    ok "$dest"
}

# Portable Claude/agent layer. Individual links (not all of ~/.claude) so
# machine-local state — settings, history, credentials — stays untouched.
link "claude/CLAUDE.md"  "$HOME/.claude/CLAUDE.md"
link "claude/commands"   "$HOME/.claude/commands"
link "claude/CLAUDE.md"  "$HOME/.codex/AGENTS.md"    # same rules for AGENTS.md-reading tools

link ".zshrc"            "$HOME/.zshrc"
link ".functions"        "$HOME/.local/bin/.functions"
link ".gitconfig"        "$HOME/.gitconfig"
link ".gitignore_global" "$HOME/.gitignore_global"
link ".editorconfig"     "$HOME/.editorconfig"
link "starship.toml"     "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
link "ghostty_config"    "$GHOSTTY_DEST"

# ---------------------------------------------------------------------------
# 3. Git identity (kept out of the tracked, public .gitconfig)
# ---------------------------------------------------------------------------
bold "Git identity"
LOCAL_GITCONFIG="$HOME/.gitconfig.local"
if [[ -f "$LOCAL_GITCONFIG" ]]; then
    ok "$LOCAL_GITCONFIG already exists"
else
    cat > "$LOCAL_GITCONFIG" <<'EOF'
# Machine-local git identity. Not tracked.
[user]
    name = Adrian TJ
    email = adrian.tame.jacobo@gmail.com
    # signingkey = <ssh-or-gpg-key>
EOF
    ok "Created $LOCAL_GITCONFIG"
fi

# ---------------------------------------------------------------------------
bold "Done."
info "Open a new terminal, or run:  exec zsh"
