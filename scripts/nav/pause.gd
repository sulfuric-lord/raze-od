extends Control

@onready var level_label = $VBoxContainer/Label4
@onready var score_label = $VBoxContainer/Label2
@onready var deaths_label = $VBoxContainer/Label3
var GameManager

func _ready() -> void:
	await get_tree().process_frame
	GameManager = get_tree().get_first_node_in_group("GameManager")
	process_mode = Node.PROCESS_MODE_ALWAYS
	print(GameManager)

func update_info():
	level_label.text = "LEVEL %d" % GameManager.current_level

	if GameManager.current_level == 2:
		var remaining_time = max(0, GameManager.survive_time - GameManager.level_timer)

		score_label.text = "REMAINING TIME: %02d:%02d" % [
			int(remaining_time) / 60,
			int(remaining_time) % 60
		]
	else:
		score_label.text = "RAZE: %d /// %d :ALIENS" % [
			GameManager.player_kills,
			GameManager.enemy_kills
		]

	deaths_label.text = "DEATHS: %d" % GameManager.player_deaths
	
func _on_button_pressed():
	visible = false
	get_tree().paused = false

func _on_button_2_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
