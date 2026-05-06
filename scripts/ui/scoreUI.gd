extends Control

@export var g: Node2D
@onready var ammo_label = $Label
@export var is_timer: bool


func _process(delta: float) -> void:
	if !is_timer:
		ammo_label.text = "RAZE: %s /// %s :ALIENS" % [g.player_kills, g.enemy_kills]
	else:
		ammo_label.text = "%s:%s" % [floor(g.level_timer/60), posmod(g.level_timer, 60)]
		
