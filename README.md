# 🐚 dotfiles

A clean, minimal macOS setup focused on a fast terminal, a sane git workflow,
and a polyglot dev environment (Python · Go · Rust · TypeScript · LaTeX).

Everything optional is **guarded** — a config is a no-op on a machine where the
underlying tool isn't installed yet, so these files are safe to drop onto a
fresh Mac before you've finished `brew install`-ing everything.

## 📦 What's inside

| File | Symlink target | Purpose |
| :--- | :--- | :--- |
| [`.zshrc`](.zshrc) | `~/.zshrc` | Shell: history, completions, plugins, tools, prompt |
| [`.functions`](.functions) | `~/.local/bin/.functions` | Custom shell functions (sourced by `.zshrc`) |
| [`.gitconfig`](.gitconfig) | `~/.gitconfig` | Git defaults + aliases (identity lives in `~/.gitconfig.local`) |
| [`.gitignore_global`](.gitignore_global) | `~/.gitignore_global` | OS/editor/build junk ignored in **every** repo |
| [`.editorconfig`](.editorconfig) | `~/.editorconfig` | Consistent whitespace across editors & languages |
| [`starship.toml`](starship.toml) | `~/.config/starship.toml` | Compact, language-aware prompt |
| [`ghostty_config`](ghostty_config) | `~/Library/Application Support/com.mitchellh.ghostty/config` | Terminal emulator config |

## 🚀 Install

Clone, then symlink. From the repo directory:

```bash
DOT="$PWD"

mkdir -p ~/.local/bin ~/.config

ln -sf "$DOT/.zshrc"            ~/.zshrc
ln -sf "$DOT/.functions"        ~/.local/bin/.functions
ln -sf "$DOT/.gitconfig"        ~/.gitconfig
ln -sf "$DOT/.gitignore_global" ~/.gitignore_global
ln -sf "$DOT/.editorconfig"     ~/.editorconfig
ln -sf "$DOT/starship.toml"     ~/.config/starship.toml
ln -sf "$DOT/ghostty_config"    "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
```

Then set your git identity **outside** the tracked config (this file is public):

```bash
cat > ~/.gitconfig.local <<'EOF'
[user]
    name = Adrian TJ
    email = you@example.com
    # signingkey = <ssh-or-gpg-key>   # optional
EOF
```

### Dependencies

Install the CLI extras the configs light up:

```bash
brew install starship fzf zoxide eza bat mise \
             zsh-autosuggestions zsh-syntax-highlighting
```

Nothing here breaks if a tool is missing — you'll just get the plain version of
that feature until you install it.

## ✨ Shell functions

Defined in [`.functions`](.functions):

| Command | Description |
| :--- | :--- |
| `calc "<expr>"` | Quick precision CLI calculator (`noglob`, so `*` works). |
| `brewdo` | `brew update && upgrade && cleanup -s` in one go. |
| `gap "msg"` | `git add -A`, commit, push — **refuses** to auto-push on `main`/`master`. |
| `myip` | Print your public IP. |
| `del <files>` | Safe delete: lists targets and asks first (does **not** shadow `rm`). |
| `mkcd <dir>` | Make a directory (and parents) and `cd` into it. |
| `gclone <url\|owner/repo>` | Clone a repo and `cd` into it. Accepts GitHub shorthand. |
| `extract <archive>` | Unpack almost any archive without remembering flags. |

## 🔧 Git aliases

From [`.gitconfig`](.gitconfig) — run any as `git <alias>`:

| Alias | Expands to |
| :--- | :--- |
| `st` | `status -sb` |
| `co` / `sw` / `br` | `checkout` / `switch` / `branch` |
| `lg` | Pretty one-line commit graph |
| `last` | Show the most recent commit with its diffstat |
| `undo` | Undo the last commit, keep changes staged |
| `amend` | Amend the last commit, reuse the message |
| `unstage` | Unstage files (`reset HEAD --`) |
| `aliases` | List all configured aliases |

Also enabled by default: `push.autoSetupRemote` (first push needs no `-u`),
rebase-on-pull, prune-on-fetch, `rerere`, histogram diffs, and `zdiff3`
conflict markers.

## 🐚 Shell features (`.zshrc`)

- **History** — shared across sessions, de-duplicated, timestamped, 50k entries.
- **Navigation** — `AUTO_CD` (type a dir to enter it), `AUTO_PUSHD`, and
  case-insensitive completion.
- **Plugins** — `zsh-autosuggestions` + `zsh-syntax-highlighting`.
- **[fzf](https://github.com/junegunn/fzf)** — `Ctrl-R` history, `Ctrl-T` files, `Alt-C` cd.
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** — `z <partial>` jumps to your most-used matching dir.
- **[eza](https://github.com/eza-community/eza)** — `ls`/`ll`/`lt` (tree) with git awareness.
- **[starship](https://starship.rs)** — the prompt.
- **[mise](https://mise.jdx.dev)** — one runtime manager for Python/Node/Go/etc.

Core tools (`cat`, `rm`) are intentionally left untouched — `bat` is available
as `catp` and safe delete as `del`, so scripts and other machines behave normally.

## 🎨 Terminal aesthetic

- **Terminal:** [Ghostty](https://ghostty.org)
- **Font:** UbuntuMono Nerd Font Mono, 16pt
- **Theme:** Monokai Pro (auto light/dark)
- **Quick terminal:** ``Cmd + ` ``
