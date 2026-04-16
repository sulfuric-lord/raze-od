extends Node

@export var enemy_scene: PackedScene
@export var max_enemies: int = 6
@export var ally_scene: PackedScene
@export var max_allies: int = 4

var spawn_points = []
var enemies = []
var allies = []

var player_kills := 0
var enemy_kills := 0

func _ready():
	spawn_points = get_tree().get_nodes_in_group("spawn_points")
	for e in get_tree().get_nodes_in_group("entities"):
		connect_entity(e)

func _process(delta):
	print(player_kills, enemy_kills)
	cleanup_entities()
	
	if enemies.size() < max_enemies:
		spawn_enemy()
	if allies.size() <  max_allies:
		spawn_ally()
	

func cleanup_entities():
	enemies = enemies.filter(func(e):
		return is_instance_valid(e)
	)
	allies = allies.filter(func(e):
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
	connect_entity(enemy)
	
func spawn_ally():
	if spawn_points.is_empty():
		return
	
	var point = spawn_points.pick_random()
	var ally = ally_scene.instantiate()
	
	ally.global_position = point.global_position
	get_tree().current_scene.add_child(ally)
	
	allies.append(ally)
	connect_entity(ally)

func connect_entity(e):
	if e.has_signal("died"):
		e.connect("died", Callable(self, "_on_entity_died"))

func _on_entity_died(entity):
	if not entity.has_node("Team"):
		return
	
	var team = entity.get_node("Team").team
	
	if team == 2:
		player_kills += 1
	elif team == 1:
		enemy_kills += 1
