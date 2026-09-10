extends Node

var save_path := "user://savegame.data"
var settings_path := "user://settings.data"

# Once have more settings, save settings to a config file.


func save_settings():
	print("Saving Settings...")
	var settings_file = FileAccess.open(settings_path, FileAccess.WRITE)

	var settings_data = {
		"soundDB": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX Bus")),
		"musicDB": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music Bus")),
		"gameColor": ColorManager.colors[ColorManager.currentColor][0],
		"cameraShake": GameManager.screenShakeOn,
	}

	settings_file.store_var(settings_data)
	print("Settings Saved")
	
func save_game():
	print("Saving Game...")
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	
	var save_data = {
		"needTutorial" : GameManager.need_tutorial,
		"maxLevel" : GameManager.max_level,
		"hints" : GameManager.amt_of_hints
	}
	
	save_file.store_var(save_data)
	print("Game Saved")


func load_game():
	print("Loading game...")
	print("Loading Settings")
	if not FileAccess.file_exists(settings_path):
		print("No settings file found!")
		ColorManager.change_color(0) # Set the icons to default, as they can't be preloaded as .svg.txt in the main theme
	else: 

		var file = FileAccess.open(settings_path, FileAccess.READ)
		var data = file.get_var()
		print("Settings File Retreved...")

		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX Bus"), data.get("soundDB", 0))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music Bus"), data.get("musicDB", 0))
		ColorManager.change_color(ColorManager.get_color_idx(data.get("gameColor", "Blue")))
		GameManager.screenShakeOn = data.get("cameraShake", true)
		print("Settings Loaded")
	
	if not FileAccess.file_exists(save_path):
		print("No save file found!")
	else:
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data : Dictionary= file.get_var()
		
		GameManager.max_level = data.get("maxLevel", 1)
		GameManager.amt_of_hints = data.get("hints", 0)
		GameManager.need_tutorial = data.get("needTutorial", true)
	print("Game Loaded")
