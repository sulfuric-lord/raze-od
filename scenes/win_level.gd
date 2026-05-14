extends Control

func _ready() -> void:
	load_and_show()

func load_and_show():
	if not FileAccess.file_exists("user://save.json"):
		return
	
	var file = FileAccess.open("user://save.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	if data == null:
		return
	
	var level = int(data.get("last_completed_level", 1))
	var level_data = data.get(str(level), {})
	
	var kills = int(level_data.get("player_kills", 0))
	var deaths = int(level_data.get("player_deaths", 0))
	var enemy_kills = int(level_data.get("enemy_kills", 0))
	print("LOAD:", data)
	
	$VBoxContainer/Label2.text = "RAZE: %s // %s :ALIENS" % [kills, enemy_kills]
	$VBoxContainer/Label3.text = "Your deaths: %s" % [deaths]


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
