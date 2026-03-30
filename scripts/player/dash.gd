extends Node2D

@onready var player := get_parent() as CharacterBody2D
@onready var stats := get_parent().get_node("stats")

var dash_timer := 0.0
var cooldown_timer := 0.0
var dash_dir := 0.0

func _physics_process(delta: float) -> void:
	if dash_timer > 0:
		dash_timer -= delta

	if cooldown_timer > 0:
		cooldown_timer -= delta

	if Input.is_action_just_pressed("dash") and cooldown_timer <= 0:
		start_dash()

func start_dash():
	dash_timer = stats.dash_time
	cooldown_timer = stats.dash_cooldown
	dash_dir = player.check_direction()
	if dash_dir == 0:
		dash_dir = 1

func is_dashing() -> bool:
	return dash_timer > 0

func get_vel_override() -> Vector2:
	if not is_dashing():
		return Vector2.ZERO
	return Vector2(dash_dir * stats.dash_speed, 0)
