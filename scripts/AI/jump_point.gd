extends Area2D
class_name JumpPoint

@export var jump_direction := Vector2(1, -1)
@export var jump_force := 600.0

func _ready():
	add_to_group("jump_points")
