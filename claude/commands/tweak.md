---
description: Change a local config setting via the dotfiles repo, never the live file
---

Config change requested: $ARGUMENTS

My configs are symlinks into my dotfiles repo (`~/dotfiles`). The repo is the
source of truth — edit there, never the symlink target's live copy elsewhere.

1. Work out which file owns the setting:
   - shell behavior / aliases / PATH → `.zshrc`
   - shell functions → `.functions`
   - git behavior → `.gitconfig` (identity goes in `~/.gitconfig.local`, untracked)
   - prompt → `starship.toml`
   - terminal (font, theme, keybinds) → `ghostty_config`
   - global ignores → `.gitignore_global`
   - editor whitespace → `.editorconfig`
2. Check the tool's docs for the correct option name/syntax if not certain —
   don't guess config keys.
3. Make the edit, matching the file's existing style and comments.
4. Tell me how to reload it (`exec zsh`, Ghostty reload, etc.) — or reload it
   yourself if it's shell-level and testable.
5. Commit the change in the dotfiles repo on the current branch with a clear
   one-liner. Don't push unless I ask.

If the setting is secret or machine-specific (tokens, work-only overrides),
put it in the appropriate untracked local file (e.g. `~/.gitconfig.local`)
and say so instead of committing it.
