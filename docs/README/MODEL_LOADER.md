# model_loader.gd

Loads one VRM into a scene node.

## Call

`load_vrm(path)` returns a dictionary:

- `ok` is true when the model is usable.
- `actor` is the imported scene. The caller adds it to the tree.
- `skeleton` is the single `Skeleton3D`.
- `error` is empty on success and a short reason otherwise.

## Checks

The file must be a glTF 2 binary whose length matches the header. Import uses the VRM extensions in `addons/vrm`. The result must contain one skeleton with the humanoid bones used by the old companion: hips, both legs, both feet, both arms, and both hands. Anything else is freed and refused.

A ready model prints `SPATIAL_COMPANY_MODEL_READY` with the bone and mesh counts.

## Test

`tests/model_loader.gd` refuses a missing file, a short file, a non-glTF file, and a glTF with no skeleton. Set `SPATIAL_COMPANY_VRM` to a real VRM path to also check a successful load.
