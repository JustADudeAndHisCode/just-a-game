extends Node2D

const TILE_SIZE := Vector2i(16, 16)
const TILE_GROUND := 0
const TILE_WATER := 1
const TILE_FIRE := 2

@export var level_layout: Array[String] = []
@export var tile_scale: int = 3

@onready var tile_map: TileMap = %TileMap
@onready var collision_root: Node2D = %TileCollisions
@onready var editor_label: Label = %EditorLabel

var tile_data: Dictionary = {}
var selected_tile := TILE_GROUND
var editor_enabled := false

func _ready() -> void:
    _setup_tileset()
    _build_level_from_layout()
    _refresh_editor_label()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_editor"):
        editor_enabled = !editor_enabled
        _refresh_editor_label()
        return

    if event.is_action_pressed("select_tile_1"):
        selected_tile = TILE_GROUND
        _refresh_editor_label()
    elif event.is_action_pressed("select_tile_2"):
        selected_tile = TILE_WATER
        _refresh_editor_label()
    elif event.is_action_pressed("select_tile_3"):
        selected_tile = TILE_FIRE
        _refresh_editor_label()

    if not editor_enabled:
        return

    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        var local_mouse = tile_map.to_local(get_global_mouse_position())
        var cell = tile_map.local_to_map(local_mouse)
        _set_tile(cell, selected_tile)

func _setup_tileset() -> void:
    var tileset = TileSet.new()
    tileset.tile_size = TILE_SIZE
    var atlas = TileSetAtlasSource.new()
    atlas.texture = preload("res://assets/tiles/basic_tiles.png")
    atlas.texture_region_size = TILE_SIZE
    var source_id = tileset.add_source(atlas)
    atlas.create_tile(Vector2i(0, 0))
    atlas.create_tile(Vector2i(1, 0))
    atlas.create_tile(Vector2i(2, 0))
    tile_map.tile_set = tileset
    tile_map.scale = Vector2(tile_scale, tile_scale)
    tile_map.set_meta("source_id", source_id)

func _build_level_from_layout() -> void:
    tile_data.clear()
    tile_map.clear()
    for y in range(level_layout.size()):
        var row = level_layout[y]
        for x in range(row.length()):
            var tile_char = row[x]
            var tile_type = _char_to_tile(tile_char)
            if tile_type == null:
                continue
            var cell = Vector2i(x, y)
            tile_data[cell] = tile_type
            _draw_tile(cell, tile_type)
    _rebuild_collisions()

func _char_to_tile(tile_char: String) -> Variant:
    match tile_char:
        "G":
            return TILE_GROUND
        "W":
            return TILE_WATER
        "F":
            return TILE_FIRE
        _:
            return null

func _set_tile(cell: Vector2i, tile_type: int) -> void:
    tile_data[cell] = tile_type
    _draw_tile(cell, tile_type)
    _rebuild_collisions()

func _draw_tile(cell: Vector2i, tile_type: int) -> void:
    var source_id = int(tile_map.get_meta("source_id"))
    var atlas_coords = Vector2i(tile_type, 0)
    tile_map.set_cell(0, cell, source_id, atlas_coords)

func _rebuild_collisions() -> void:
    for child in collision_root.get_children():
        child.queue_free()

    for cell in tile_data.keys():
        if tile_data[cell] != TILE_GROUND:
            continue
        var body = StaticBody2D.new()
        var shape = CollisionShape2D.new()
        var rect = RectangleShape2D.new()
        rect.size = Vector2(TILE_SIZE.x, TILE_SIZE.y) * tile_scale
        shape.shape = rect
        shape.position = Vector2(cell.x, cell.y) * TILE_SIZE * tile_scale + rect.size * 0.5
        body.add_child(shape)
        collision_root.add_child(body)

func _refresh_editor_label() -> void:
    if not is_instance_valid(editor_label):
        return
    var tile_name = "Ground"
    match selected_tile:
        TILE_WATER:
            tile_name = "Water"
        TILE_FIRE:
            tile_name = "Fire"
    var editor_state = "ON" if editor_enabled else "OFF"
    editor_label.text = "Editor: %s | Tile: %s (1-3)" % [editor_state, tile_name]
