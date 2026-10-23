extends SceneTree

const ModelLoader = preload("res://model_loader.gd")
const Launcher = preload("res://launcher.gd")
const HUMANOID_COUNT := 13

func _initialize() -> void:
    _run.call_deferred()

func _fail(message: String) -> void:
    push_error(message)
    print("SPATIAL_COMPANY_MODEL_FAIL ", message)
    quit(1)

func _glb(json: String) -> PackedByteArray:
    var payload := json.to_utf8_buffer()
    while payload.size() % 4 != 0:
        payload.append(0x20)
    var total := 12 + 8 + payload.size()
    var bytes := PackedByteArray()
    bytes.resize(total)
    bytes.encode_u32(0, 0x46546C67)
    bytes.encode_u32(4, 2)
    bytes.encode_u32(8, total)
    bytes.encode_u32(12, payload.size())
    bytes.encode_u32(16, 0x4E4F534A)
    for i in payload.size():
        bytes[20 + i] = payload[i]
    return bytes

func _run() -> void:
    var chosen: String = Launcher.model_from_args(PackedStringArray(["--model=/tmp/character.vrm", "--other"]))
    if chosen != "/tmp/character.vrm":
        _fail("a --model argument should be the file to open")
        return
    var positional: String = Launcher.model_from_args(PackedStringArray(["notes.txt", "/tmp/other.VRM"]))
    if positional != "/tmp/other.VRM":
        _fail("a VRM path on the command line should be the file to open")
        return
    if not Launcher.model_from_args(PackedStringArray(["--spatial"])).is_empty():
        _fail("unrelated arguments should leave the model unset")
        return
    var loader: RefCounted = ModelLoader.new()
    var missing: Dictionary = loader.load_vrm("/tmp/spatial-company-missing.vrm")
    if bool(missing.ok) or str(missing.error) != "File not found.":
        _fail("a missing file should be refused")
        return
    var tiny := FileAccess.open("/tmp/spatial-company-tiny.vrm", FileAccess.WRITE)
    tiny.store_string("not a model")
    tiny.close()
    var small: Dictionary = loader.load_vrm("/tmp/spatial-company-tiny.vrm")
    if bool(small.ok) or str(small.error) != "File is too small to be a VRM.":
        _fail("a short file should be refused")
        return
    var junk := FileAccess.open("/tmp/spatial-company-junk.vrm", FileAccess.WRITE)
    junk.store_buffer(PackedByteArray())
    for _i in 32:
        junk.store_8(1)
    junk.close()
    var bad: Dictionary = loader.load_vrm("/tmp/spatial-company-junk.vrm")
    if bool(bad.ok) or str(bad.error) != "File is not a VRM (glTF binary).":
        _fail("a non-glTF file should be refused")
        return
    var empty := _glb('{"asset":{"version":"2.0"},"scene":0,"scenes":[{"nodes":[0]}],"nodes":[{"name":"Empty"}]}')
    var empty_file := FileAccess.open("/tmp/spatial-company-empty.vrm", FileAccess.WRITE)
    empty_file.store_buffer(empty)
    empty_file.close()
    var no_body: Dictionary = loader.load_vrm("/tmp/spatial-company-empty.vrm")
    if bool(no_body.ok) or str(no_body.error).is_empty():
        _fail("a glTF without a humanoid skeleton should be refused")
        return
    if no_body.actor != null:
        _fail("a refused model should not leave a scene behind")
        return
    var sample := OS.get_environment("SPATIAL_COMPANY_VRM")
    if not sample.is_empty():
        var real: Dictionary = loader.load_vrm(sample)
        if not bool(real.ok):
            _fail(str(real.error))
            return
        var skeleton: Skeleton3D = real.skeleton
        if skeleton.get_bone_count() < HUMANOID_COUNT:
            _fail("a humanoid VRM should keep the required bones")
            return
        real.actor.free()
    print("SPATIAL_COMPANY_MODEL_PASS")
    quit(0)
