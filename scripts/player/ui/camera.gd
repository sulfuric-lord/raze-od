extends Camera2D

@export var look_strength : float = 0.2
@export var smooth : float = 8.0

@onready var player := get_parent()

func _process(delta):
	var player_pos : Vector2 = player.global_position
	var mouse_pos := get_global_mouse_position()

	var target := player_pos.lerp(mouse_pos, look_strength)

	global_position = global_position.lerp(target, smooth * delta)
