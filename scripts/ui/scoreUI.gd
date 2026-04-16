extends Control

@export var g: Node2D
@onready var ammo_label = $Label


func _process(delta: float) -> void:
	ammo_label.text = "RAZE: %s /// %s :ALIENS" % [g.player_kills, g.enemy_kills]
	pass
