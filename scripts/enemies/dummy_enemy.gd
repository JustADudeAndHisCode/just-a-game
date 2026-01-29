extends StaticBody2D

@export var max_health := 3

@onready var health_label: Label = %HealthLabel

var health := 0

func _ready() -> void:
    add_to_group("enemies")
    health = max_health
    _update_label()

func apply_damage(amount: int) -> void:
    health = max(0, health - amount)
    _update_label()
    if health == 0:
        queue_free()

func _update_label() -> void:
    if is_instance_valid(health_label):
        health_label.text = "Dummy HP: %d" % health
