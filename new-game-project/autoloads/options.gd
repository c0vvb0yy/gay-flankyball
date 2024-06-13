extends Node

const OPTIONS_PATH := "user://preferences.cfg"
const SAVEGAME_PATH := "user://savegame.json"

var master_volume := 1.0
var music_volume := 1.0
var sfx_volume := 1.0

var fullscreen := false
var text_speed := 60
var auto_continue_delay := 1.0
var auto_continue := false

func _ready() -> void:
	var config = ConfigFile.new()

	var err = config.load(OPTIONS_PATH)

	if err != OK:
		print("ERR")
		return

	music_volume = config.get_value("preferences", "music_volume", 1.0)
	master_volume = config.get_value("preferences", "master_volume", 1.0)
	sfx_volume = config.get_value("preferences", "sfx_volume", 1.0)
	text_speed = config.get_value("preferences", "text_speed", 60)
	auto_continue_delay = config.get_value("preferences", "auto_continue_delay", 1.0)
	auto_continue = config.get_value("preferences", "auto_continue", false)
	set_fullscreen(config.get_value("preferences", "fullscreen", false))
	
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(master_volume)
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(music_volume)
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(sfx_volume)
	)
func set_fullscreen(value:bool):
	fullscreen = value
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	
func save_prefs():
	var config = ConfigFile.new()

	# Store some values.
	config.set_value("preferences", "master_volume", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))))
	config.set_value("preferences", "music_volume", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))))
	config.set_value("preferences", "sfx_volume", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))))
	config.set_value("preferences", "text_speed", text_speed)
	config.set_value("preferences", "auto_continue", auto_continue)
	config.set_value("preferences", "auto_continue_delay", auto_continue_delay)
	config.set_value("preferences", "fullscreen", fullscreen)

	# Save it to a file (overwrite if already exists).
	config.save(OPTIONS_PATH)

func does_savegame_exist():
	if not ResourceLoader.exists(SAVEGAME_PATH):
		return false
	return true

func save_gamestate():
	var data_to_save := {}
	data_to_save["Sound"] = Sound.serialize()
	data_to_save["GameWorld"] = GameWorld.serialize()
	
	var file = FileAccess.open(SAVEGAME_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data_to_save, "\t"))
	file.close()

func load_gamestate():
	var file = FileAccess.open(SAVEGAME_PATH, FileAccess.READ)
	if not file:
		push_warning(str("No file at ", SAVEGAME_PATH))
		return {}
	
	var data : Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	Sound.deserialize(data.get("Sound", {}))
	GameWorld.deserialize(data.get("GameWorld", {}))
