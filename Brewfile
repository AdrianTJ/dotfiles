# Brewfile — declarative dependency list for these dotfiles.
# Install/update everything with:  brew bundle --file=Brewfile
# (install.sh does this for you.)

# --- Shell experience ---
brew "starship"                 # prompt
brew "fzf"                      # fuzzy finder (Ctrl-R / Ctrl-T / Alt-C)
brew "zoxide"                   # smarter cd
brew "eza"                      # modern ls
brew "bat"                      # pretty cat (aliased as `catp`)
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# --- Utilities used by .functions ---
brew "bc"                       # calc()
brew "mosh"                     # roaming SSH for flaky connections
brew "uv"                       # Python project/venv manager
brew "tailscale"                # VPN

# --- Runtime manager (Python / Node / Go / ...) ---
brew "mise"
brew "gh"                        # git credential helper (see .gitconfig)

# --- Terminal + font (font fixes Nerd Font glyphs in the prompt) ---
cask "ghostty"
cask "font-ioskeley-mono"
