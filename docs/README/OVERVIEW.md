# Spatial Company

Standalone companion. The headset panel and Frametop come later. This version opens a VRM and shows it.

On the Frame it is installed at `/run/media/steamos/SD512/spatial-company`.

## Now

- `launcher.gd` is the window. Open a model, or pass one on the command line.
- `model_loader.gd` reads a VRM and requires one humanoid skeleton.
- The VRM importer in `addons/vrm` and the MToon materials in `addons/Godot-MToon-Shader` are the V-Sekai addons, both MIT.
- No bundled character. No animation. No settings screen.

## Later

- A motion pack played on the loaded model.
- The headset overlay, using the same preview camera as a starting point.
- A Frametop client for screen and room facts, used only when Frametop is running.
- A separate debug menu for the options that used to live in the old settings screen.
