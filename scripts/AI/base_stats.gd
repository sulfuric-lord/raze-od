extends Node2D

var maxHp : int = 1000
var hp : int
signal died(entity)

func _ready():
	hp = maxHp

func take_damage(amount: float):
	print("ай")
	hp -= amount
	
	if hp <= 0:
		die()

func die():
	emit_signal("died", self)
