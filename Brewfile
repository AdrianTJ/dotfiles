# Brewfile — declarative dependency list for these dotfiles.
# Install/update everything with:  brew bundle --file=Brewfile
# (install.sh does this for you.)

# --- Shell experience ---
brew "starship"                 # prompt
brew "fzf"                      # fuzzy finder (Ctrl-R / Ctrl-T / Alt-C)
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
cask "font-jetbrains-mono-nerd-font"

# --- GUI apps the environment depends on ---
# handy + hyperkey are a pair, not a preference: handy/apply.sh pins
# keyboard_implementation = tauri *because* Hyperkey maps Caps Lock to every
# modifier by ORing them into each key event rather than emitting the
# flagsChanged events Handy's default tracker reads. With the default tracker,
# the Hyperkey+Space binding registers but never fires — so a machine with Handy
# and no Hyperkey has an unusable hotkey.
cask "handy"                     # local dictation (see handy/apply.sh)
cask "hyperkey"                  # Caps Lock -> all modifiers; provides the hotkey
cask "rectangle"                 # window management
cask "stats"                     # menu bar system stats
