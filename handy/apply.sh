#!/usr/bin/env bash
#
# apply.sh — write the tracked Handy dictation settings into Handy's store.
#
# Handy keeps its config in a Tauri store that it rewrites on every change, so
# this is applied rather than symlinked: a symlink would be clobbered the next
# time Handy saves. Only the keys in settings.fragment.json are touched;
# everything else in the store (history limits, post-processing, keys) is left
# alone. Idempotent — re-run any time.
#
# The settings here are deliberately non-default:
#   keyboard_implementation = tauri
#     The default (handy_keys) tracks modifier state from flagsChanged events,
#     which the Hyperkey app never emits — it ORs the modifiers into each key
#     event instead. With handy_keys, Hyperkey+Space registers but never fires.
#   reliable_paste = true, paste_delay_after_ms = 800
#     Reliable paste publishes the transcript as a promise on the pasteboard
#     and restores only once the target actually reads it, rather than on a
#     fixed timer. That read is the only delivery evidence macOS offers, and the
#     observability is the point: a failed insertion logs either "clipboard read
#     Xms after chord" or "no read within timeout" instead of nothing at all.
#     paste_delay_after_ms then governs only the fallback path, so 800 ms is
#     margin rather than a race to win.
#     History: disabled 2026-09-12 after a long transcript failed to paste into
#     a terminal. That conclusion is now suspect — the read receipt we blamed
#     may have come from a different application entirely, since a failing
#     burst was later traced to a non-target window. Re-enabled because flying
#     blind cost more than the suspected race.
#   selected_model = ...Q8_0.gguf
#     Parakeet Unified EN 0.6B. Handy resolves it from the shared Hugging Face
#     cache, so there is a single copy of the model on disk.
#   custom_words = [...]
#     Handy matches these fuzzily against the transcript with a Soundex
#     phonetic boost, so an entry that merely *sounds* like everyday English
#     silently rewrites ordinary dictation (ONNX ate "once", OpenAI ate "open",
#     RAG ate "rag"). Only collision-free terms are tracked; adding a word that
#     sounds like common speech will corrupt normal dictation.
#   clipboard_handling = copy_to_clipboard
#     Handy otherwise restores the previous clipboard after dictating. Leaving
#     the transcript there instead means a late or failed read still finds it,
#     and it suits a workflow that already copies transcripts by hand. The
#     original justification for this (a "two-pass read" inside Orca's Electron
#     terminal) is now unproven — see the paste_method note below.
#   paste_method = ctrl_v (the macOS default, pinned only to revert the earlier
#   "direct" experiment — apply.sh merges keys and cannot remove a stale one).
#     Do not set this to "direct" on macOS. Direct types through enigo, which
#     posts CGEventKeyboardSetUnicodeString events in 20-character chunks with
#     keycode 0, no key-up, and cleared flags. Upstream calls it a known-broken
#     path for terminals and intends to remove it (cjpais/Handy#692: "just use
#     cmd+v on macOS"), and a Handy fork disabled it on macOS because it causes
#     CGEvent duplication in Ghostty. Worse, enigo's 20 ms inter-event pacing
#     lives in its Drop impl, and Handy keeps its Enigo alive for the whole
#     process lifetime, so that pacing never executes: events are posted back to
#     back (measured 634 µs for a 74-character transcript) with no
#     acknowledgement from the target. "Text pasted successfully in Xµs" is an
#     enqueue metric, not a delivery metric.
#
# Order matters: Handy holds the store in memory and rewrites the whole file
# when it exits, so a running instance clobbers any external merge on quit.
# Quit it first, then merge, then start it — otherwise exactly the keys this
# script is trying to change are the ones that silently revert.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
store="$HOME/Library/Application Support/com.pais.handy/settings_store.json"
fragment="$here/settings.fragment.json"

if [ "$(uname -s)" != "Darwin" ]; then
    echo "  handy: not macOS, skipping"
    exit 0
fi
if [ ! -d "$(dirname "$store")" ]; then
    echo "  handy: not installed, skipping"
    exit 0
fi
if [ ! -f "$store" ]; then
    echo "  handy: no settings store yet — launch Handy once, then re-run"
    exit 0
fi

# Handy rewrites the store from memory on exit, so it must be stopped before
# the merge — not after, or its shutdown flush undoes the merge.
was_running=false
if pgrep -f "Handy.app/Contents/MacOS/handy" >/dev/null 2>&1; then
    was_running=true
    osascript -e 'tell application "Handy" to quit' >/dev/null 2>&1 || true
    for _ in $(seq 1 20); do
        pgrep -q -f "Handy.app/Contents/MacOS/handy" || break
        sleep 0.5
    done
fi

python3 - "$store" "$fragment" <<'PY'
import json
import os
import sys

store_path, fragment_path = sys.argv[1], sys.argv[2]

with open(store_path) as fh:
    store = json.load(fh)
with open(fragment_path) as fh:
    fragment = json.load(fh)


def merge(dst, src):
    for key, value in src.items():
        if isinstance(value, dict) and isinstance(dst.get(key), dict):
            merge(dst[key], value)
        else:
            dst[key] = value


settings = store.setdefault("settings", {})
merge(settings, fragment)

tmp = f"{store_path}.tmp"
with open(tmp, "w") as fh:
    json.dump(store, fh, indent=2)
os.replace(tmp, store_path)

print("  handy: applied " + ", ".join(sorted(fragment)))
PY

# Handy reads the store at startup, so bring it back up (and only if it was).
if [ "$was_running" = true ]; then
    open -a Handy
    echo "  handy: restarted"
fi
