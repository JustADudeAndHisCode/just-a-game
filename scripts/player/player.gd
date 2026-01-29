extends CharacterBody2D

@export var speed := 240.0
@export var acceleration := 1400.0
@export var friction := 1600.0
@export var jump_velocity := -420.0
@export var gravity := 1100.0
@export var coyote_time := 0.12
@export var jump_buffer := 0.12
@export var dash_speed := 520.0
@export var dash_time := 0.16
@export var dash_cooldown := 0.35
@export var wall_slide_speed := 120.0
@export var wall_jump_velocity := Vector2(320.0, -420.0)
@export var attack_damage := 1
@export var attack_duration := 0.18
@export var attack_cooldown := 0.25

@onready var attack_area: Area2D = %AttackArea
@onready var attack_shape: CollisionShape2D = %AttackShape

var facing := 1
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var attack_timer := 0.0
var attack_cooldown_timer := 0.0

func _ready() -> void:
    attack_shape.disabled = true
    attack_area.body_entered.connect(_on_attack_body_entered)

func _physics_process(delta: float) -> void:
    var input_axis = Input.get_axis("move_left", "move_right")
    if input_axis != 0:
        facing = sign(input_axis)

    coyote_timer = max(0.0, coyote_timer - delta)
    jump_buffer_timer = max(0.0, jump_buffer_timer - delta)
    dash_cooldown_timer = max(0.0, dash_cooldown_timer - delta)
    attack_cooldown_timer = max(0.0, attack_cooldown_timer - delta)

    if is_on_floor():
        coyote_timer = coyote_time

    if Input.is_action_just_pressed("jump"):
        jump_buffer_timer = jump_buffer

    if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0:
        dash_timer = dash_time
        dash_cooldown_timer = dash_cooldown

    if Input.is_action_just_pressed("attack") and attack_cooldown_timer <= 0.0:
        _start_attack()

    if dash_timer > 0.0:
        dash_timer -= delta
        velocity = Vector2(facing * dash_speed, 0.0)
        move_and_slide()
        return

    if is_on_wall() and not is_on_floor() and velocity.y > 0.0:
        velocity.y = min(velocity.y, wall_slide_speed)
        if Input.is_action_just_pressed("jump"):
            var wall_dir = get_wall_normal().x
            velocity = Vector2(-wall_dir * wall_jump_velocity.x, wall_jump_velocity.y)
            move_and_slide()
            return

    if coyote_timer > 0.0 and jump_buffer_timer > 0.0:
        velocity.y = jump_velocity
        coyote_timer = 0.0
        jump_buffer_timer = 0.0

    if not is_on_floor():
        velocity.y += gravity * delta

    if input_axis != 0:
        velocity.x = move_toward(velocity.x, input_axis * speed, acceleration * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, friction * delta)

    move_and_slide()

    if attack_timer > 0.0:
        attack_timer = max(0.0, attack_timer - delta)
        if attack_timer == 0.0:
            attack_shape.disabled = true

func _start_attack() -> void:
    attack_timer = attack_duration
    attack_cooldown_timer = attack_cooldown
    attack_shape.disabled = false
    var offset = Vector2(18 * facing, -4)
    attack_area.position = offset

func _on_attack_body_entered(body: Node) -> void:
    if not body.is_in_group("enemies"):
        return
    if body.has_method("apply_damage"):
        body.apply_damage(attack_damage)
