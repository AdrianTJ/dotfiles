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
#   reliable_paste = false, paste_delay_after_ms = 800
#     Reliable paste publishes the transcript as a lazy promise on the macOS
#     pasteboard instead of real data. Ghostty (and terminals generally) read a
#     large payload in two passes: it pings the promise, then re-reads for the
#     content. Handy tears the promise down after a ~200 ms quiet period, so the
#     second read finds the previous clipboard and the transcript vanishes
#     silently. Short text fits the first read, which is why the failure looked
#     intermittent. The plain-text path materialises the data up front (the
#     target reads ~106 ms after the chord), so 800 ms of margin before the
#     unconditional restore is ample. Revisit if upstream fixes the two-pass
#     read. paste_delay_ms stays at its 60 ms default and is not pinned here.
#   selected_model = ...Q8_0.gguf
#     Parakeet Unified EN 0.6B. Handy resolves it from the shared Hugging Face
#     cache, so there is a single copy of the model on disk.
#   custom_words = [...]
#     Handy matches these fuzzily against the transcript with a Soundex
#     phonetic boost, so an entry that merely *sounds* like everyday English
#     silently rewrites ordinary dictation (ONNX ate "once", OpenAI ate "open",
#     RAG ate "rag"). Only collision-free terms are tracked; adding a word that
#     sounds like common speech will corrupt normal dictation.

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

# Handy reads the store at startup, so restart it if it is running.
if pgrep -f "Handy.app/Contents/MacOS/handy" >/dev/null 2>&1; then
    osascript -e 'tell application "Handy" to quit' >/dev/null 2>&1 || true
    for _ in $(seq 1 20); do
        pgrep -q -f "Handy.app/Contents/MacOS/handy" || break
        sleep 0.5
    done
    open -a Handy
    echo "  handy: restarted"
fi
