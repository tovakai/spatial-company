# launcher.gd

Desktop window that shows one VRM.

## Run

```
godot --path . -- /path/to/character.vrm
godot --path . -- --model=/path/to/character.vrm
./launch.sh -- /path/to/character.vrm
```

Godot 4.7, compatibility renderer. `launch.sh` uses `godot` on `PATH`.

## Behavior

- **Open model** picks a `.vrm` from disk.
- A path in the command line is opened on startup. `--model=` wins over a bare `.vrm` path.
- The last successful path is stored in `user://launcher.cfg` and reopened next time.
- Drag the view to turn around the model. The wheel moves the camera closer or farther.
- A file that fails to load leaves the previous model in place and writes the reason on the status line.
- The camera looks at a standing body from the front. There is no animation.

## Scene

`launcher.tscn` is this script on a full-window control. The 3D view, light, and file dialog are created when the window opens.
