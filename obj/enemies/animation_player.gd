extends AnimationPlayer

var body = get_parent() as CharacterBody2D
var current_anim = ""

func _process(delta):
	var new_anim = ""

	if body.velocity.x == 0:
		new_anim = "idle"
	else:
		new_anim = "walk"

		if body.velocity.x > 0:
			$Skeleton2D.scale.x = -1
		else:
			$Skeleton2D.scale.x = 1

	if current_anim != new_anim:
		play(new_anim)
		current_anim = new_anim
