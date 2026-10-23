#!/bin/sh
cd "$(dirname "$0")" || exit 1
if [ -x ./runtime/godot ]; then
    GODOT=./runtime/godot
elif command -v godot >/dev/null 2>&1; then
    GODOT=godot
else
    echo "Godot 4.7 is required: ./runtime/godot or godot on PATH." >&2
    exit 1
fi
exec "$GODOT" --path . "$@"
