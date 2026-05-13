extends Node

@export var enemy_scene: PackedScene
@export var max_enemies: int = 6
@export var ally_scene: PackedScene
@export var max_allies: int = 4
@export var current_level: int
@export var goal: int

var game_ended := false

var spawn_points = []
var enemies = []
var allies = []

var player_kills := 0
var enemy_kills := 0

var player_deaths := 0

# Для второго уровня
var survive_time := 180.0 # 3 минуты
var level_timer := 0.0

func _ready():
	add_to_group("GameManager")
	spawn_points = get_tree().get_nodes_in_group("spawn_points")
	
	for e in get_tree().get_nodes_in_group("entities"):
		connect_entity(e)

func _process(delta):
	if game_ended:
		return
	
	cleanup_entities()
	if current_level <= 3:
		if enemies.size() < max_enemies:
			spawn_enemy()
			
		if allies.size() < max_allies:
			spawn_ally()
	
	# Логика второго уровня
	if current_level == 2:
		level_timer += delta
		
		if level_timer >= survive_time:
			game_ended = true
			save_game()
			await get_tree().process_frame
			call_deferred("_go_to_win")
		
		if player_deaths >= 3:
			game_ended = true
			await get_tree().process_frame
			call_deferred("game_over")

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
	if entity.is_in_group("player"):
		player_deaths += 1
		
		# Только для второго уровня
		if current_level == 2 and not game_ended:
			game_ended = true
			game_over()
			return
	
	if not entity.has_node("Team"):
		return
	
	var team = entity.get_node("Team").team
	
	if team == 2:
		player_kills += 1
		check_win()
	elif team == 1:
		enemy_kills += 1

func save_game():
	var data = {}
	
	if FileAccess.file_exists("user://save.json"):
		var file = FileAccess.open("user://save.json", FileAccess.READ)
		data = JSON.parse_string(file.get_as_text())
		file.close()
	
	if data == null:
		data = {}
	
	data["last_level_updated"] = current_level
	
	data[str(current_level)] = {
		"player_kills": player_kills,
		"enemy_kills": enemy_kills,
		"player_deaths": player_deaths
	}
	
	print("SAVING:", data)
	
	var file = FileAccess.open("user://save.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func check_win():
	# На втором уровне победа только по таймеру
	if current_level == 2:
		return
	
	if player_kills >= goal and not game_ended:
		game_ended = true
		save_game()
		await get_tree().process_frame
		call_deferred("_go_to_win")

func _go_to_win():
	var tree = Engine.get_main_loop() as SceneTree
	
	if tree:
		tree.change_scene_to_file("res://scenes/win_level.tscn")

func game_over():
	var tree = Engine.get_main_loop() as SceneTree
	
	if tree:
		tree.change_scene_to_file("res://scenes/game_over.tscn")

func spawn_enemy_at_points(points):
	for point in points:
		var enemy = enemy_scene.instantiate()
		
		enemy.global_position = point.global_position
		get_tree().current_scene.add_child(enemy)
		
		enemies.append(enemy)
		connect_entity(enemy)
