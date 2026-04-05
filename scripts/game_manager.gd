extends Node

@export var enemy_scene: PackedScene
@export var max_enemies: int = 6

var spawn_points = []
var enemies = []

func _ready():
	spawn_points = get_tree().get_nodes_in_group("spawn_points")

func _process(delta):
	print(spawn_points)
	cleanup_enemies()
	
	if enemies.size() < max_enemies:
		spawn_enemy()

func cleanup_enemies():
	enemies = enemies.filter(func(e):
		return is_instance_valid(e)
	)

func spawn_enemy():
	if spawn_points.is_empty():
		return
	
	var point = spawn_points.pick_random()
	var enemy = enemy_scene.instantiate()
	
	enemy.global_position = point.global_position
	get_tree().current_scene.add_child(enemy)
	
	enemies.append(enemy)
