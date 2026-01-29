extends Area2D

@export var minigame_scene := "res://scenes/minigames/ArcadeStub.tscn"

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if body is CharacterBody2D:
        MinigameManager.enter_minigame(minigame_scene)
