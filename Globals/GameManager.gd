extends Node

# Level Variables
var current_word := "" ## Current word that puzzle is on
var starting_word := "" ## The word the player starts with
var target_word := "" ## The word the player is trying to get to
var solution := "" ## Stores the letters needed for the solution in the order they will be used
var solution_long := [] ## Stores solution in words instead of just letters

var current_game_version := "v03.b" ## Current game version number

var current_levels := [0, 0, 0, 0] ## Progress on each difficulty level. 
var current_difficulty := 0 ## Current Difficulty Level
var amt_of_hints := 0 ## Amount of hints the player has remaining

# Settings Variables
var screen_shake_on = true ## Controls wether the screen shakes when a word is not in the dictonary

var tutorial_mode = false ## True if the player is in the tutorial
var need_tutorial = true ## True if the player needs to play the tutorial

var daily_mode = false ## True if the player is currently playing the daily level
var daily_time = 0 ## In tenth of seconds, Time that player took to complete the daily level
var daily_completed = false ## True if the player has already played the daily level in the current day (UTC)
var day_of_year = -1: ## Day of the year (UTC)
	set(value):
		day_of_year = value
		if day_of_year != -1:
			daily_completed = last_day_completed == day_of_year
var last_day_completed = -1 ## Last day that the daily puzzle was completed.

## Nickname that is used for the CheddaBoards leader board. 
## Must have completed a daily puzzle to have
var nickname = "" 


func _ready() -> void:
	randomize()
	FileManager.load_game()

	# Set up CheddaBoards
	var file = FileAccess.open("res://api_key.json", FileAccess.READ)
	var raw_data = file.get_as_text()
	file.close()
	var data = JSON.parse_string(raw_data)
	var api_key = data.cheddaboards_api_key

	CheddaBoards.set_api_key(str(api_key))
	CheddaBoards.set_game_id("word-chains")

	# Connect status signals
	CheddaBoards.login_success.connect(_on_chedda_login_success)
	CheddaBoards.login_failed.connect(_on_chedda_login_failed)
	CheddaBoards.nickname_error.connect(
		func(error):
			print("nickname error: " + error),
	)
	CheddaBoards.nickname_changed.connect(
		func(new_nickname):
			print("nickname changed: " + new_nickname),
	)

	CheddaBoards.login_anonymous(nickname)

	# Fetch current day of the year
	LevelDatabase.fetch_date()

	# Set up PostHog Anylitics
	await PostHog.initialized
	PostHog.auto_include_properties["distribution_platform"] = "itchio"
	PostHog.auto_include_properties["game_version"] = current_game_version
	PostHog.capture("GAME_START")


func _on_chedda_login_success(nickname):
	print(nickname + " login successful")


func _on_chedda_login_failed(error):
	print("CheddaBoards login failed: ", error)


## Populates GameManagers level variables with the new level data
## Returns true if level_num is a valid level, and everything is updated accordingly
func load_level(difficulty: int, level_num: int) -> bool:
	print("LOADING LEVEL")

	# Set up Signal Resolver to tell when one of two signals is recived.
	var error = { "result": "fail" } # This needs to be a dictonary to be accesed by a lamda func
	var resolver = SignalResolver.new()

	LevelDatabase.level_loaded.connect(
		func():
			print("RECEIVED: SUCCESS")
			error.result = "success"
			resolver.done.emit(),
		CONNECT_ONE_SHOT,
	)

	LevelDatabase.level_load_fail.connect(
		func():
			print("RECEIVED: FAIL")
			error.result = "fail"
			resolver.done.emit(),
		CONNECT_ONE_SHOT,
	)

	LevelDatabase.load_level(difficulty, level_num)
	await resolver.done

	print("RESOLVER DONE")

	# Evaluate the result of SignalResolver
	if error.result == "success":
		print("LEVEL LOADED")
		return true

	print("LEVEL FAILED TO LOAD")
	return false

## Changes the scene to settings
func open_settings():
	get_tree().change_scene_to_file("res://_Frames/settings.tscn")

## Changes the scene to credits
func open_credits():
	get_tree().change_scene_to_file("res://_Frames/credits.tscn")

## Changes the scene to level select, or if tutorial is needed, to the tutorial
func open_level_select():
	if not need_tutorial:
		get_tree().change_scene_to_file("res://_Frames/level_select.tscn")
	else:
		tutorial_mode = true
		load_level(0, 0)
		get_tree().change_scene_to_file("res://_GameFrame/game.tscn")

## Changes the scene to the game frame
func start_game():
	get_tree().change_scene_to_file("res://_GameFrame/game.tscn")

## Changes the scene to the main menu
func back_to_menu():
	get_tree().change_scene_to_file("res://_Frames/menu.tscn")

## Loads the daily puzzle and changes the scene to the game frame
func load_daily_puzzle(panel: Panel):
	if GameManager.day_of_year != -1: # If day of the year isn't loaded yet
		# Set up Signal Resolver to tell when one of two signals is recived.
		var error = { "response_code": 0 } # This needs to be a dictonary to be accesed by a lamda
		var resolver = SignalResolver.new()

		LevelDatabase.daily_failed.connect(
			func(response):
				error.response_code = response
				resolver.done.emit(),
			CONNECT_ONE_SHOT,
		)

		LevelDatabase.request_received.connect(
			func(value):
				error.response_code = value
				resolver.done.emit(),
			CONNECT_ONE_SHOT,
		)

		LevelDatabase.fetch_date()
		await resolver.done

		# Evaluate the result of SignalResolver
		if error.response_code == 200: # Success
			daily_mode = true
			LevelDatabase.load_daily_level()
			get_tree().change_scene_to_file("res://_GameFrame/game.tscn")
		else: # Error
			var label: Label = panel.get_child(0)
			label.text = "Error loading daily puzzle. \n Error code: " + str(error.response_code)
	else:
		daily_mode = true
		LevelDatabase.load_daily_level()
		get_tree().change_scene_to_file("res://_GameFrame/game.tscn")

## Opens the leaderboard frame
func open_leaderboard():
	get_tree().change_scene_to_file("res://_Frames/leaderboard.tscn")

## Signal Resolver is used when you need to await one or more signals at a time 
## and have a diffrent outcome for each.
class SignalResolver:
	@warning_ignore("unused_signal")
	signal done
