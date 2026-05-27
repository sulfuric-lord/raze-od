extends Control

@export var player: Node2D
@onready var s := player.get_node("stats") as Node
@onready var ammo_label = $Label


func _process(delta: float) -> void:
	ammo_label.text = "HP:%s/%s" % [s.hp, s.maxHp]
	pass
