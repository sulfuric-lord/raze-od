extends StaticBody2D

func _ready() -> void:
	add_to_group("doors")

func open():
	hide()
	$CollisionShape2D.disabled = true

func close():
	show()
	$CollisionShape2D.disabled = false
