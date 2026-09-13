#!/usr/bin/env bash
#
# paste.sh — deliver Handy's transcript into the focused application.
#
# Installed by apply.sh to ~/.local/bin/handy-paste and selected via
# paste_method = external_script. Handy invokes it with the transcript as
# argv[1] (see paste_via_external_script in Handy's clipboard.rs).
#
# Why this exists: Handy's own macOS paste chords go out through enigo, which
# posts key events with EMPTY modifier flags — in that crate `event_flags` is
# only ever read, never populated. Native AppKit apps paste regardless, because
# they take the modifier from the V event itself. Chromium/Electron targets
# build their tracked modifier state from the flag carried on the Cmd-down
# event, conclude "Command is up", and drop the chord silently — no paste, no
# error, and Handy still logs "Text pasted successfully". Measured here: three
# of four attempts logged "[reliable-paste] no read within timeout", meaning
# nothing ever read the pasteboard at all.
#
# AppleScript's System Events synthesises the chord through the Accessibility
# API with correct modifier tracking, which every target honours — verified by
# hand into Orca's terminal before this script existed.
#
# Note: this replaces the clipboard contents with the transcript and does not
# restore what was there before, which matches clipboard_handling =
# copy_to_clipboard elsewhere in the tracked settings.

set -euo pipefail

text="${1-}"

# Nothing to do for an empty transcript (Handy can emit one for a silent clip).
[ -n "$text" ] || exit 0

printf '%s' "$text" | pbcopy

# Give the pasteboard a moment to settle before the chord reads it.
sleep 0.05

osascript -e 'tell application "System Events" to keystroke "v" using command down'
