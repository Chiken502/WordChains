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
		"hintFlash": GameManager.hint_flashing
	}

	settings_file.store_var(settings_data)
	print("Settings Saved")


## Saves game progress to save_path
func save_game():
	print("Saving Game...")
	GameManager.change_dicts(DictionaryManager.current_dict, DictionaryManager.current_dict) # Saves level progress for diff lang
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
		"lastLanguage": DictionaryManager.current_dict,
		"enLevelData": GameManager.en_levels,
		"deLevelData": GameManager.de_levels,
		"esLevelData": GameManager.es_levels,
		"frLevelData": GameManager.fr_levels,
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
	
	var settings_data: Dictionary = {}
	if not FileAccess.file_exists(settings_path):
		print("No settings file found!")

		# Set the icons to default, as they can't be preloaded as .svg.txt in the main theme
		ColorManager.change_color(ColorManager.current_color)
	else:
		var file = FileAccess.open(settings_path, FileAccess.READ)
		settings_data = file.get_var()
		print("Settings File Retrieved...")

	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX Bus"),
		settings_data.get("soundDB", 0),
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music Bus"),
		settings_data.get("musicDB", 0),
	)
	ColorManager.change_color(ColorManager.get_color_idx(settings_data.get("gameColor", "Blue")))
	GameManager.screen_shake_on = settings_data.get("cameraShake", true)
	GameManager.hint_flashing = settings_data.get("hintFlash", true)
	print("Settings Loaded")

	var save_data : Dictionary = {}
	if not FileAccess.file_exists(save_path):
		print("No save file found!")
	else:
		var file = FileAccess.open(save_path, FileAccess.READ)
		save_data = file.get_var()

	GameManager.current_levels = save_data.get("current_levels", [0, 0, 0, 0])
	GameManager.amt_of_hints = save_data.get("hints", 1)
	GameManager.need_tutorial = save_data.get("needTutorial", true)
	GameManager.nickname = save_data.get("nickname", "")
	GameManager.last_day_completed = save_data.get("lastDailyComplete", -1)
	GameManager.last_difficulty = save_data.get("lastDifficulty", 0)
	DictionaryManager.change_dictionary(save_data.get("lastLanguage", "EN"))
	GameManager.en_levels = save_data.get("enLevelData", [[0, 0, 0, 0], GameManager.defults_levels_to_hints.duplicate()])
	GameManager.de_levels = save_data.get("deLevelData", [[0, 0, 0, 0], GameManager.defults_levels_to_hints.duplicate()])
	GameManager.es_levels = save_data.get("esLevelData", [[0, 0, 0, 0], GameManager.defults_levels_to_hints.duplicate()])
	GameManager.fr_levels = save_data.get("frLevelData", [[0, 0, 0, 0], GameManager.defults_levels_to_hints.duplicate()])
	GameManager.change_dicts(DictionaryManager.current_dict)
	if GameManager.levels_to_hint == []:
		GameManager.levels_to_hint = GameManager.defults_levels_to_hints.duplicate()
	
	GameManager.daily_puzzles_completed = save_data.get("dailyPuzzlesCompleted", 0)
	GameManager.total_timed_mode_puzzles_completed = save_data.get("totalTimedLevelsCompleted", 0)
	GameManager.best_timed_mode = save_data.get("bestTimedMode", 0)
	GameManager.total_hints_used = save_data.get("totalHintsUsed", 0)
	GameManager.total_undos_used = save_data.get("totalUndosUsed", 0)
	GameManager.total_letters_dragged = save_data.get("totalLetterDragged", 0)
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
