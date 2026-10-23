#!/bin/sh
cd "$(dirname "$0")" || exit 1
if ! command -v godot >/dev/null 2>&1; then
    echo "Godot 4.7 is required on PATH." >&2
    exit 1
fi
exec godot --path . "$@"
