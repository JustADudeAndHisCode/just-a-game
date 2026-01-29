extends Control

const LEVELS := [
    {"name": "Level 1", "path": "res://scenes/Level1.tscn"},
    {"name": "Level 2", "path": "res://scenes/Level2.tscn"},
]

@onready var start_button: Button = %StartButton
@onready var load_selected_button: Button = %LoadSelectedButton
@onready var level_select: OptionButton = %LevelSelect
@onready var master_slider: HSlider = %MasterSlider
@onready var sfx_slider: HSlider = %SfxSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var voice_slider: HSlider = %VoiceSlider

func _ready() -> void:
    _ensure_buses()
    for level in LEVELS:
        level_select.add_item(level.name)

    _sync_slider_to_bus(master_slider, "Master")
    _sync_slider_to_bus(sfx_slider, "SFX")
    _sync_slider_to_bus(music_slider, "Music")
    _sync_slider_to_bus(voice_slider, "Voice")

    start_button.pressed.connect(_on_start_pressed)
    load_selected_button.pressed.connect(_on_load_selected_pressed)
    master_slider.value_changed.connect(func(value): _apply_volume("Master", value))
    sfx_slider.value_changed.connect(func(value): _apply_volume("SFX", value))
    music_slider.value_changed.connect(func(value): _apply_volume("Music", value))
    voice_slider.value_changed.connect(func(value): _apply_volume("Voice", value))

func _ensure_buses() -> void:
    var required = ["SFX", "Music", "Voice"]
    for bus_name in required:
        if AudioServer.get_bus_index(bus_name) == -1:
            AudioServer.add_bus(AudioServer.get_bus_count())
            AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, bus_name)

func _sync_slider_to_bus(slider: HSlider, bus_name: String) -> void:
    var bus_index = AudioServer.get_bus_index(bus_name)
    if bus_index == -1:
        slider.value = 0
        return
    slider.value = AudioServer.get_bus_volume_db(bus_index)

func _apply_volume(bus_name: String, value: float) -> void:
    var bus_index = AudioServer.get_bus_index(bus_name)
    if bus_index == -1:
        return
    AudioServer.set_bus_volume_db(bus_index, value)

func _on_start_pressed() -> void:
    get_tree().change_scene_to_file(LEVELS[0].path)

func _on_load_selected_pressed() -> void:
    var index = level_select.selected
    if index < 0 or index >= LEVELS.size():
        return
    get_tree().change_scene_to_file(LEVELS[index].path)
