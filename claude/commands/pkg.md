---
description: Install packages with Homebrew and keep the dotfiles Brewfile in sync
---

Install and track: $ARGUMENTS

My Brewfile lives in my dotfiles repo (find it via `ls ~/dotfiles/Brewfile`
or `brew bundle dump` location; ask me if you can't locate the repo).

1. For each requested package, figure out whether it's a formula or a cask
   (`brew info <name>`); if the name is ambiguous or not found, search with
   `brew search` and confirm with me before installing.
2. `brew install` (or `brew install --cask`) it.
3. Add it to the Brewfile in the dotfiles repo, in the section where it
   belongs, with a short trailing comment saying what it's for — matching the
   file's existing style. Skip if already listed.
4. In the dotfiles repo, commit just the Brewfile change on the current
   branch with a one-line message like `Add ripgrep to Brewfile`.
   Don't push unless I ask.

If I ask to *remove* a package instead: `brew uninstall`, delete its Brewfile
line, same commit flow.
