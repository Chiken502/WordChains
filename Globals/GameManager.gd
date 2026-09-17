extends Node

# Level Varibles
var current_word := ""
var starting_word := ""
var target_word := ""
var solution := "" ## Stores the letters needed for the solution in the order they will be used
var solution_long := [] ## Stores solution in words instead of just letters

var current_game_version := "v03.b"

var current_level := 0
var max_level := 0
var amt_of_hints := 0

# Settings Varibles
var screenShakeOn = true

var tutorial_mode = false
var need_tutorial = true

var daily_mode = false
var daily_time = 0 # seconds
var daily_completed = false
var day_of_year = -1:
	set(value):
		day_of_year = value
		if day_of_year != -1:
			daily_completed = last_day_completed == day_of_year
var last_day_completed = -1

var nickname = ""


func _ready() -> void:
	randomize()
	FileManager.load_game()

	var file = FileAccess.open("res://api_key.json", FileAccess.READ)
	var raw_data = file.get_as_text()
	file.close()
	var data = JSON.parse_string(raw_data)
	var api_key = data.cheddaboards_api_key

	print(api_key)

	CheddaBoards.set_api_key(str(api_key))
	CheddaBoards.set_game_id("word-chains")
	
	CheddaBoards.login_success.connect(_on_chedda_login_success)
	CheddaBoards.login_failed.connect(_on_chedda_login_failed)
	CheddaBoards.nickname_error.connect(func(error): print("nickname error: "+error))
	CheddaBoards.nickname_changed.connect(func(new_nickname): print("nickname changed: " + new_nickname))

	
	CheddaBoards.login_anonymous(nickname)
	
	LevelDatabase.fetch_date()

	await PostHog.initialized
	PostHog.auto_include_properties["distribution_platform"] = "itchio"
	PostHog.auto_include_properties["game_version"] = current_game_version
	PostHog.capture("GAME_START")

func _on_chedda_login_success(_nickname):
	print(_nickname + " login successful")

func _on_chedda_login_failed(error):
	print("CheddaBoards login failed: ", error)

## Populates GameManagers level varibles with the new level data
## Returns true if level_num is a valid level, and everything is updated accordingly
func load_level(level_num) -> bool:
	if level_num <= len(LevelDatabase.levels) - 1:
		var next_level := LevelDatabase.levels[level_num]

		if level_num > max_level:
			max_level = level_num
			FileManager.save_game()

		current_level = level_num
		starting_word = next_level[0]
		current_word = starting_word
		target_word = next_level[1]
		solution = next_level[2]
		solution_long = next_level[3].split(",")

		return true
	return false


func open_settings():
	get_tree().change_scene_to_file("res://_Frames/settings.tscn")


func open_credits():
	get_tree().change_scene_to_file("res://_Frames/credits.tscn")


func open_level_select():
	if not need_tutorial:
		get_tree().change_scene_to_file("res://_Frames/level_select.tscn")
	else:
		tutorial_mode = true
		load_level(0)
		get_tree().change_scene_to_file("res://_GameFrame/game.tscn")


func start_game():
	load_level(current_level)
	get_tree().change_scene_to_file("res://_GameFrame/game.tscn")


func back_to_menu():
	get_tree().change_scene_to_file("res://_Frames/menu.tscn")


func load_daily_puzzle(panel: Panel):
	if GameManager.day_of_year != -1:
		var error = { "response_code": 0 }
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

		if error.response_code == 200:
			daily_mode = true
			LevelDatabase.load_daily_level()
			get_tree().change_scene_to_file("res://_GameFrame/game.tscn")
		else:
			var label: Label = panel.get_child(0)
			label.text = "Error loading daily puzzle. \n Error code: " + str(error.response_code)
	else:
		daily_mode = true
		LevelDatabase.load_daily_level()
		get_tree().change_scene_to_file("res://_GameFrame/game.tscn")

func open_leaderboard():
	get_tree().change_scene_to_file("res://_Frames/leaderboard.tscn")

class SignalResolver:
	signal done
