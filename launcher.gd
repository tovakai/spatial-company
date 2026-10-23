extends Control

const ModelLoader = preload("res://model_loader.gd")

var view: SubViewport
var camera: Camera3D
var actor: Node3D
var path_label: Label
var status_label: Label
var dialog: FileDialog
var config := ConfigFile.new()
var focus := Vector3(0, 0.9, 0)
var yaw := 0.0
var pitch := 0.0
var distance := 2.8

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build()
    config.load("user://launcher.cfg")
    var requested := model_from_args(OS.get_cmdline_user_args())
    if requested.is_empty():
        requested = str(config.get_value("launcher", "model", ""))
    if not requested.is_empty():
        open_model(requested)
    else:
        status_label.text = "Open a VRM to begin."

static func model_from_args(args: PackedStringArray) -> String:
    for arg in args:
        if arg.begins_with("--model="):
            return arg.trim_prefix("--model=")
        if arg.get_extension().to_lower() == "vrm":
            return arg
    return ""

func _build() -> void:
    var root := VBoxContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_theme_constant_override("separation", 0)
    add_child(root)

    var bar := HBoxContainer.new()
    bar.add_theme_constant_override("separation", 12)
    bar.offset_left = 8
    root.add_child(bar)
    var open := Button.new()
    open.text = "Open model"
    open.pressed.connect(_choose)
    bar.add_child(open)
    path_label = Label.new()
    path_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    path_label.clip_text = true
    path_label.text = "No model"
    bar.add_child(path_label)

    var frame := SubViewportContainer.new()
    frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
    frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    frame.stretch = true
    frame.gui_input.connect(_view_input)
    root.add_child(frame)

    view = SubViewport.new()
    view.size = Vector2i(1280, 720)
    view.own_world_3d = true
    view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    view.msaa_3d = Viewport.MSAA_2X
    frame.add_child(view)

    var world := WorldEnvironment.new()
    world.environment = Environment.new()
    world.environment.background_mode = Environment.BG_COLOR
    world.environment.background_color = Color("1a1d24")
    world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    world.environment.ambient_light_color = Color.WHITE
    world.environment.ambient_light_energy = 0.45
    view.add_child(world)
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-20, -25, 0)
    light.light_energy = 0.8
    view.add_child(light)
    camera = Camera3D.new()
    camera.fov = 40
    view.add_child(camera)
    _place_camera()

    status_label = Label.new()
    status_label.offset_left = 8
    root.add_child(status_label)

    dialog = FileDialog.new()
    dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    dialog.access = FileDialog.ACCESS_FILESYSTEM
    dialog.filters = PackedStringArray(["*.vrm ; VRM model"])
    dialog.title = "Open VRM"
    dialog.file_selected.connect(open_model)
    add_child(dialog)

func open_model(path: String) -> void:
    var loaded: Dictionary = ModelLoader.new().load_vrm(path)
    if not bool(loaded.ok):
        status_label.text = str(loaded.error)
        return
    if is_instance_valid(actor):
        actor.queue_free()
    actor = loaded.actor
    view.add_child(actor)
    path_label.text = path.get_file()
    status_label.text = "Loaded %s" % path.get_file()
    yaw = 0.0
    pitch = 0.0
    distance = 2.8
    _place_camera()
    config.set_value("launcher", "model", path)
    config.save("user://launcher.cfg")

func _choose() -> void:
    dialog.popup_centered_ratio(0.7)

func _view_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        var motion := event as InputEventMouseMotion
        if motion.button_mask & MOUSE_BUTTON_MASK_LEFT:
            yaw -= motion.relative.x * 0.01
            pitch = clampf(pitch - motion.relative.y * 0.005, -0.8, 0.8)
            _place_camera()
    elif event is InputEventMouseButton and event.pressed:
        var button := event as InputEventMouseButton
        if button.button_index == MOUSE_BUTTON_WHEEL_UP:
            distance = clampf(distance - 0.15, 0.8, 8.0)
            _place_camera()
        elif button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            distance = clampf(distance + 0.15, 0.8, 8.0)
            _place_camera()

func _place_camera() -> void:
    var offset := Basis.from_euler(Vector3(pitch, yaw, 0)) * Vector3(0, 0, distance)
    camera.position = focus + offset
    camera.look_at(focus, Vector3.UP)
