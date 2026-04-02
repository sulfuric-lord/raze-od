extends Node2D

# MOVEMENT_STATS
@export var speed: float = 400.0
@export var gravity: float = 2000.0
@export var jump_speed: float = 1000.0
@export var max_jumps: int = 2

# DASH_STATS
var dash_time: float = 0.06
var dash_speed: float = 2000.0
@export var dash_cooldown: float = 1.2

#HP_STATS
var maxHp : int = 30
var hp : int

func _ready():
	hp = maxHp

func take_damage(amount: float):
	hp -= amount
	
	if hp <= 0:
		die()

func die():
	queue_free()

func heal(amount: float):
	hp += amount
	hp = clamp(hp, 0, maxHp)
