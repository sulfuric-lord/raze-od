extends Control

@export var player: Node2D
@onready var w := player.get_node("Weapon") as Node
@onready var ammo_label = $AmmoLabel


func _process(delta: float) -> void:
	ammo_label.text = "%s\n%s" % [str(w.weapons[w.idx].name), w.displayable_ammo]
	pass
