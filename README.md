# 🐚 dotfiles

A clean and minimal set of configuration files for macOS, focused on productivity and a streamlined terminal experience.

## 📦 What's inside?

- **[Zsh](.zshrc):** Configured with syntax highlighting and smart autocompletions.
- **[Ghostty](ghostty_config):** A high-performance terminal emulator config using *UbuntuMono Nerd Font* and *Monokai Pro* themes.
- **[Functions](.functions):** A collection of handy shell utilities to speed up common tasks.

## ✨ Custom Functions

| Command | Description |
| :--- | :--- |
| `calc` | A quick CLI calculator with precision support. |
| `brewdo` | Update, upgrade, and cleanup Homebrew in one go. |
| `gap "msg"` | The ultimate shortcut: `git add .`, `commit`, and `push`. |

## 🚀 Quick Start

To use these dotfiles, you can symlink them to your home directory:

```bash
ln -s ~/path/to/dotfiles/.zshrc ~/.zshrc
ln -s ~/path/to/dotfiles/.functions ~/.local/bin/.functions
# Symlink Ghostty config based on your OS path
```

## 🎨 Terminal Aesthetic

- **Font:** UbuntuMono Nerd Font Mono
- **Theme:** Monokai Pro (Dark/Light support)
- **Features:** Quick terminal toggle via `Cmd + \``
