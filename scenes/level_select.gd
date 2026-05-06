extends Control

func _ready():
	$CenterContainer/VBoxContainer/level1.mouse_entered.connect(func(): update_info("Hellrasiers", "It was a surprise attack. Aliens have landed on Earth and are planning to destroy all life here. You must fend off the first blow."))
	$CenterContainer/VBoxContainer/level2.mouse_entered.connect(func(): update_info("Expect a fight", "LOCKED"))
	$CenterContainer/VBoxContainer/level3.mouse_entered.connect(func(): update_info("The hunt", "LOCKED"))
	$CenterContainer/VBoxContainer/level4.mouse_entered.connect(func(): update_info("Grand Finale", "LOCKED"))

	for button in $CenterContainer/VBoxContainer.get_children():
		button.pressed.connect(func():
			on_level_selected(button)
		)

func update_info(name, desc):
	$LevelNameLabel.text = name
	$LevelInfoLabel.text = desc


func on_level_selected(button):
	if button.name == "level1":
		get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
