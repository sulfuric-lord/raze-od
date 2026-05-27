extends Control

@onready var music_slider = $CenterContainer/VBoxContainer/music
@onready var sfx_slider = $CenterContainer/VBoxContainer/sfx

const SETTINGS_PATH = "user://settings.cfg"

func _ready():
	load_settings()

	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	
func _on_music_changed(value):
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)

	save_settings()

func _on_sfx_changed(value):
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)

	save_settings()
	

func save_settings():
	var config = ConfigFile.new()

	config.set_value("audio", "music", music_slider.value)
	config.set_value("audio", "sfx", sfx_slider.value)

	config.save(SETTINGS_PATH)
	
func load_settings():
	var config = ConfigFile.new()

	if config.load(SETTINGS_PATH) != OK:
		return

	var music = config.get_value("audio", "music", 1.0)
	var sfx = config.get_value("audio", "sfx", 1.0)

	music_slider.value = music
	sfx_slider.value = sfx

	_on_music_changed(music)
	_on_sfx_changed(sfx)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
