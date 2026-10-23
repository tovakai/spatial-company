extends RefCounted

const VRM_EXTENSIONS: Array[Script] = [
    preload("res://addons/vrm/vrm_extension.gd"),
    preload("res://addons/vrm/1.0/VRMC_vrm.gd"),
    preload("res://addons/vrm/1.0/VRMC_node_constraint.gd"),
    preload("res://addons/vrm/1.0/VRMC_springBone.gd"),
    preload("res://addons/vrm/1.0/VRMC_materials_hdr_emissiveMultiplier.gd"),
    preload("res://addons/vrm/1.0/VRMC_materials_mtoon.gd"),
]

const HUMANOID_BONES: PackedStringArray = [
    "Hips",
    "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot",
    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand",
]

func load_vrm(path: String) -> Dictionary:
    var header := _header_error(path)
    if not header.is_empty():
        return _fail(header)
    var extensions: Array[GLTFDocumentExtension] = []
    for script in VRM_EXTENSIONS:
        var ext: GLTFDocumentExtension = script.new()
        extensions.append(ext)
        GLTFDocument.register_gltf_document_extension(ext, true)
    var doc := GLTFDocument.new()
    var state := GLTFState.new()
    state.handle_binary_image = GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED
    var result := doc.append_from_file(path, state, 16)
    var candidate: Node3D = doc.generate_scene(state) if result == OK else null
    for ext in extensions:
        GLTFDocument.unregister_gltf_document_extension(ext)
    if candidate == null:
        return _fail("Godot could not read this VRM.")
    var found := candidate.find_children("*", "Skeleton3D", true, false)
    if found.size() != 1:
        candidate.free()
        return _fail("Model needs exactly one skeleton.")
    var skeleton: Skeleton3D = found[0]
    for bone in HUMANOID_BONES:
        if skeleton.find_bone(bone) < 0:
            candidate.free()
            return _fail("Model is missing a humanoid bone: %s" % bone)
    var meshes := candidate.find_children("*", "MeshInstance3D", true, false).size()
    print("SPATIAL_COMPANY_MODEL_READY bones=%d meshes=%d" % [skeleton.get_bone_count(), meshes])
    return {"ok": true, "actor": candidate, "skeleton": skeleton, "error": ""}

func _header_error(path: String) -> String:
    if not FileAccess.file_exists(path):
        return "File not found."
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null or file.get_length() < 20:
        return "File is too small to be a VRM."
    var magic := file.get_32()
    var version := file.get_32()
    var length := file.get_32()
    var size := file.get_length()
    file.close()
    if magic != 0x46546C67 or version != 2 or length != size:
        return "File is not a VRM (glTF binary)."
    return ""

func _fail(message: String) -> Dictionary:
    return {"ok": false, "actor": null, "skeleton": null, "error": message}
