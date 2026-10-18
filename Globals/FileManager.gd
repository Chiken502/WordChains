extends Node

var save_path := "user://savegame.data"
var settings_path := "user://settings.data"

# Once have more settings, save settings to a config file.


## Saves game settings to settings_path
func save_settings():
	print("Saving Settings...")
	var settings_file = FileAccess.open(settings_path, FileAccess.WRITE)

	var settings_data = {
		"soundDB": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX Bus")),
		"musicDB": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music Bus")),
		"gameColor": ColorManager.colors[ColorManager.current_color][0],
		"cameraShake": GameManager.screen_shake_on,
	}

	settings_file.store_var(settings_data)
	print("Settings Saved")


## Saves game progress to save_path
func save_game():
	print("Saving Game...")
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)

	var last_daily_complete = GameManager.last_day_completed

	if GameManager.daily_completed:
		last_daily_complete = GameManager.day_of_year

	var save_data = {
		"needTutorial": GameManager.need_tutorial,
		"current_levels": GameManager.current_levels,
		"hints": GameManager.amt_of_hints,
		"nickname": GameManager.nickname,
		"lastDailyComplete": last_daily_complete,
		"lastDifficulty": GameManager.last_difficulty,
		"dailyPuzzlesCompleted": GameManager.daily_puzzles_completed,
		"totalTimedLevelsCompleted": GameManager.total_timed_mode_puzzles_completed,
		"bestTimedMode": GameManager.best_timed_mode,
		"totalHintsUsed": GameManager.total_hints_used,
		"totalUndosUsed": GameManager.total_undos_used,
		"totalLetterDragged": GameManager.total_letters_dragged,
	}

	save_file.store_var(save_data)
	print("Game Saved")


## Loads game files, and assigns the values to the correct Autoloads
## Loads default values if file wasn't found to read.
func load_game():
	print("Loading game...")
	print("Loading Settings")
	if not FileAccess.file_exists(settings_path):
		print("No settings file found!")

		# Set the icons to default, as they can't be preloaded as .svg.txt in the main theme
		ColorManager.change_color(ColorManager.current_color)
	else:
		var file = FileAccess.open(settings_path, FileAccess.READ)
		var data = file.get_var()
		if data:
			print("Settings File Retrieved...")

			AudioServer.set_bus_volume_db(
				AudioServer.get_bus_index("SFX Bus"),
				data.get("soundDB", 0),
			)
			AudioServer.set_bus_volume_db(
				AudioServer.get_bus_index("Music Bus"),
				data.get("musicDB", 0),
			)
			ColorManager.change_color(ColorManager.get_color_idx(data.get("gameColor", "Blue")))
			GameManager.screen_shake_on = data.get("cameraShake", true)
			print("Settings Loaded")

	if not FileAccess.file_exists(save_path):
		print("No save file found!")
	else:
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data: Dictionary = file.get_var()

		GameManager.current_levels = data.get("current_levels", [0, 0, 0, 0])
		GameManager.amt_of_hints = data.get("hints", 0)
		GameManager.need_tutorial = data.get("needTutorial", true)
		GameManager.nickname = data.get("nickname", "")
		GameManager.last_day_completed = data.get("lastDailyComplete", -1)
		GameManager.last_difficulty = data.get("lastDifficulty", 0)
		
		GameManager.daily_puzzles_completed = data.get("dailyPuzzlesCompleted", 0)
		GameManager.total_timed_mode_puzzles_completed = data.get("totalTimedLevelsCompleted", 0)
		GameManager.best_timed_mode = data.get("bestTimedMode", 0)
		GameManager.total_hints_used = data.get("totalHintsUsed", 0)
		GameManager.total_undos_used = data.get("totalUndosUsed", 0)
		GameManager.total_letters_dragged = data.get("totalLetterDragged", 0)
	print("Game Loaded")


func erase_save_file():
	if FileAccess.file_exists(save_path):
		var error = DirAccess.remove_absolute(save_path)
		
		if error == OK:
			print("Save file deleted successfully")
			MusicManager.stop_music()
			GameManager.reset_autoload()
			save_game()
			get_tree().change_scene_to_file("res://_Frames/splash.tscn")
		else:
			print("Failed to delete save file. Error: ", error)
			push_error("Failed to delete save file. Error: ", error)
	else:
		print("No Save file found")
		push_error("No Save File Found")
