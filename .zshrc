# ~/.zshrc
#
# Everything optional is guarded, so this file stays quiet on a machine where a
# given tool isn't installed yet. Install everything with:
#   ./install.sh          (or: brew bundle --file=~/dotfiles/Brewfile)

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share history live across open sessions
setopt HIST_IGNORE_ALL_DUPS   # collapse duplicate commands
setopt HIST_IGNORE_SPACE      # a leading space keeps a command out of history
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY       # record timestamps

# ---------------------------------------------------------------------------
# Navigation & completion settings (set before Oh My Zsh runs compinit)
# ---------------------------------------------------------------------------
setopt AUTO_CD                # type a directory name to cd into it
setopt AUTO_PUSHD             # cd maintains a directory stack (cd -<TAB>)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive

# ---------------------------------------------------------------------------
# Oh My Zsh: framework, git plugin, and the candy prompt theme.
# install.sh clones it to ~/.oh-my-zsh.
# ---------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="candy"
plugins=(git)

if [[ -s "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"          # also runs compinit
else
    autoload -Uz compinit && compinit   # no Oh My Zsh yet: plain completions
fi

# ---------------------------------------------------------------------------
# Zsh plugins (Homebrew). Autosuggestions loads here. Syntax highlighting must
# be the last thing sourced, so it lives at the bottom of this file.
# ---------------------------------------------------------------------------
BREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

[[ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] \
    && source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ---------------------------------------------------------------------------
# PATH & runtime version managers
# ---------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"   # rust/rustup
[[ -d "$HOME/.lmstudio/bin" ]] && export PATH="$HOME/.lmstudio/bin:$PATH"          # LM Studio CLI (lms)
[[ -d "$HOME/.antigravity/antigravity/bin" ]] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
[[ -d "$HOME/.antigravity-ide/antigravity-ide/bin" ]] && export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"

# mise — one manager for python / node / go / etc. (https://mise.jdx.dev)
# Preferred over juggling pyenv + nvm + gvm separately. Activate only if present.
command -v mise >/dev/null && eval "$(mise activate zsh)"

# ---------------------------------------------------------------------------
# Tools (each activated only if present)
# ---------------------------------------------------------------------------
# fzf — Ctrl-R fuzzy history, Ctrl-T files, Alt-C cd. Needs fzf >= 0.48.
command -v fzf >/dev/null && source <(fzf --zsh)

# ---------------------------------------------------------------------------
# Aliases (only ls -> eza; core tools like cat/rm are left untouched on purpose)
# ---------------------------------------------------------------------------
if command -v eza >/dev/null; then
    alias ls='eza --group-directories-first'
    alias ll='eza -lah --group-directories-first --git'
    alias lt='eza --tree --level=2 --group-directories-first'
fi
command -v bat >/dev/null && alias catp='bat --paging=never'   # pretty cat, opt-in

# ---------------------------------------------------------------------------
# Custom shell functions
# ---------------------------------------------------------------------------
source ~/.local/bin/.functions

# ---------------------------------------------------------------------------
# Syntax highlighting (keep last: it must wrap every widget and keybinding)
# ---------------------------------------------------------------------------
[[ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] \
    && source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
