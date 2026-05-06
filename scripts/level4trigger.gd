extends Area2D

@onready var room = get_parent()
@onready var enemy_spawners = room.get_node("enemy_spawners")

var activated := false
var game_manager

func _ready():
	game_manager = get_tree().get_first_node_in_group("GameManager")
	body_entered.connect(_on_body_entered)
	print(game_manager)

func _on_body_entered(body):
	if activated:
		return
	
	if body.is_in_group("player"):
		activated = true
		
		var points = enemy_spawners.get_children()
		game_manager.spawn_enemy_at_points(points)
