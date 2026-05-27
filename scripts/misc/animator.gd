extends Node

@onready var body = get_parent() as CharacterBody2D
@onready var anim = body.get_node("AnimationPlayer")
@onready var skeleton = body.get_node("Skeleton2D")
@onready var weapon_sprite = body.get_node("Weapon").get_node("Sprite2D")

@export var is_player: bool = false

var current_anim: String = ""

func _process(delta):
	var vel = body.velocity
	var new_anim = ""

	if abs(vel.x) < 5:
		new_anim = "idle"
	else:
		new_anim = "walk"

	if is_player:
		var mouse_x = body.get_global_mouse_position().x

		if mouse_x > body.global_position.x:
			skeleton.scale.x = -2.3
			weapon_sprite.scale.x = 0.2
			weapon_sprite.position.x = 45
		else:
			skeleton.scale.x = 2.3
			weapon_sprite.scale.x = -0.2
			weapon_sprite.position.x = -45

	else:
		if vel.x > 0:
			skeleton.scale.x = -2.3
			weapon_sprite.scale.x = 0.2
			weapon_sprite.position.x = 45
		else:
			skeleton.scale.x = 2.3
			weapon_sprite.scale.x = -0.2
			weapon_sprite.position.x = -45

	if new_anim != current_anim:
		anim.play(new_anim)
		current_anim = new_anim
