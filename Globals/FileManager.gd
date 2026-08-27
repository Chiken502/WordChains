extends Node

var save_path := "user://savegame.data"

# Once have more settings, save settings to a config file.


func save_game():
	print("Saving Game...")
	var file = FileAccess.open(save_path, FileAccess.WRITE)

	var data = {
		"soundDB": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX Bus")),
		"musicDB": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music Bus")),
		"gameColor": ColorManager.colors[ColorManager.currentColor][0],
		"cameraShake": GameManager.screenShakeOn,
	}

	file.store_var(data)
	print("Game Saved")


func load_game():
	print("Loading game...")
	if not FileAccess.file_exists(save_path):
		print("No save file found!")
		return

	var file = FileAccess.open(save_path, FileAccess.READ)
	var data = file.get_var()
	print("File Retreved...")

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX Bus"), data["soundDB"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music Bus"), data["musicDB"])
	ColorManager.change_color(ColorManager.get_color_idx(data["gameColor"]))
	GameManager.screenShakeOn = data["cameraShake"]
	print("Game Loaded")
