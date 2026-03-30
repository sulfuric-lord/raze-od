extends  Node2D

@onready var player := get_parent() as CharacterBody2D
@onready var stats := get_parent().get_node("stats")

var jumps: int = 0
var jump_buffer_time: float = 0.0
var jump_buffer_timer: float = 0.1
var coyote_time: float = 0.0
var coyote_timer: float = 0.1

func get_vel(_delta: float, current_v: Vector2) -> Vector2:
	var v := current_v
	var direction : float = player.check_direction()
	jump_buffer_time -= _delta
	
	if player.is_on_floor():
		jumps = stats.max_jumps
		coyote_time = coyote_timer
	else:
		coyote_time -= _delta
		
	v.x = direction * stats.speed

	if not player.is_on_floor():
		v.y += stats.gravity * _delta

	if Input.is_action_just_pressed("jump"):
		jump_buffer_time = jump_buffer_timer
		
	if jump_buffer_time > 0:
		if coyote_time > 0 or jumps:
			v.y = -stats.jump_speed
			jump_buffer_time = 0
			jumps -= 1
	return v
