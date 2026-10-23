# launch.sh

Starts the launcher with Godot 4.7. `./runtime/godot` is used when that binary is present. Otherwise `godot` on `PATH` is used.

```
./launch.sh
./launch.sh -- /path/to/character.vrm
```

On the Frame the app lives at `/run/media/steamos/SD512/spatial-company`, with the ARM64 Godot binary in `runtime/godot`. Arguments after the script name are passed through to Godot.
