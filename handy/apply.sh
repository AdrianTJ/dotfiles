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
# Two settings here are deliberately non-default:
#   keyboard_implementation = tauri
#     The default (handy_keys) tracks modifier state from flagsChanged events,
#     which the Hyperkey app never emits — it ORs the modifiers into each key
#     event instead. With handy_keys, Hyperkey+Space registers but never fires.
#   selected_model = ...Q8_0.gguf
#     Parakeet Unified EN 0.6B. Handy resolves it from the shared Hugging Face
#     cache, so pi-transcribe and Handy use one copy.

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
