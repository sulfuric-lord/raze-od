extends Node

@onready var body = get_parent() as CharacterBody2D
@onready var anim = body.get_node("AnimationPlayer")
@onready var skeleton = body.get_node("Skeleton2D")

var current_anim: String = ""

func _process(delta):
	var vel = body.velocity
	var new_anim = ""

	# выбор анимации
	if abs(vel.x) < 5:
		new_anim = "idle"
	else:
		new_anim = "walk"

		# флип
		if vel.x > 0:
			skeleton.scale.x = -2.3
		else:
			skeleton.scale.x = 2.3

	# не перезапускаем каждый кадр
	if new_anim != current_anim:
		anim.play(new_anim)
		current_anim = new_anim
