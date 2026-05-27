extends Control

var level_data = {
	1: {
		"name": "Hellraisers",
		"desc": "Day 1. It was a surprise attack. Unknown predators invaded the planet, destroying 80% of it within the first few hours of the attack. The RAZE squad has mobilized and is heading to the epicenter of the battle."
	},
	2: {
		"name": "Expect a fight",
		"desc": "Day 2. Allied units have been crushed, and Earth is fighting to recapture its last remaining military bases. Hold out for reinforcements while fending off the onslaught of alien creatures."
	},
	3: {
		"name": "The hunt",
		"desc": "Day 3. Thanks to reinforcements, we managed to recapture key positions; our forces are ready to launch a counterattack."
	},
	4: {
		"name": "Grand Finale",
		"desc": "Day 4. Our unit managed to drive the predators off the planet, but they won’t get off that easily... turn their own spaceship into a alien grinder"
	}
}

func _ready():
	var unlocked_level := 1

	if FileAccess.file_exists("user://save.json"):
		var file = FileAccess.open("user://save.json", FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()

		if data != null and data.has("max_unlocked_level"):
			unlocked_level = data["max_unlocked_level"]

	for button in $CenterContainer/VBoxContainer.get_children():
		var level_number = int(button.name.replace("level", ""))

		button.pressed.connect(func():
			on_level_selected(button)
		)

		if level_number > unlocked_level:
			button.disabled = true
			
			button.mouse_entered.connect(func():
				update_info(
					level_data[level_number]["name"],
					"LOCKED"
				)
			)
		else:
			button.mouse_entered.connect(func():
				update_info(
					level_data[level_number]["name"],
					level_data[level_number]["desc"]
				)
			)

func update_info(name, desc):
	$LevelNameLabel.text = name
	$LevelInfoLabel.text = desc


func on_level_selected(button):
	if button.name == "level1":
		get_tree().change_scene_to_file("res://scenes/levels/main_scene.tscn")
	if button.name == "level2":
		get_tree().change_scene_to_file("res://scenes/levels/level2.tscn")
	if button.name == "level3":
		get_tree().change_scene_to_file("res://scenes/levels/level3.tscn")
	if button.name == "level4":
		get_tree().change_scene_to_file("res://scenes/levels/level4.tscn")
