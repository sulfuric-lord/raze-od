extends Node2D

# MOVEMENT_STATS
@export var speed: float = 400.0
@export var gravity: float = 1000.0
@export var jump_speed: float = 800.0
@export var max_jumps: int = 2

# DASH_STATS
var dash_time: float = 0.06
var dash_speed: float = 2000.0
@export var dash_cooldown: float = 0.6

#HP_STATS
var maxHp : int = 30
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
	var player = get_parent()
	
	player.is_dead = true
	player.velocity = Vector2.ZERO
	
	# выключаем всё
	player.set_physics_process(false)
	set_process(false)
	
	player.visible = false
	
	respawn(player)

func respawn(player):
	await get_tree().create_timer(3.0).timeout
	
	var spawn_points = get_tree().get_nodes_in_group("spawn_points")
	
	if spawn_points.is_empty():
		push_error("НЕТ SPAWN POINTS")
		return
	
	var spawn = spawn_points.pick_random()
	
	player.global_position = spawn.global_position
	
	# хп фулл
	hp = maxHp
	
	player.visible = true
	player.is_dead = false
	
	player.set_physics_process(true)
	set_process(true)

func heal(amount: float):
	hp += amount
	hp = clamp(hp, 0, maxHp)
