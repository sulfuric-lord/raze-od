extends Button

func _on_pressed() -> void:
		get_tree().change_scene_to_file("res://scenes/level_select.tscn")


func _on_exit_pressed():
	get_tree().quit()


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")
