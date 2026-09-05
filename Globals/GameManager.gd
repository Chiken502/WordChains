extends Node

# Level Varibles
var current_word := ""
var starting_word := ""
var target_word := ""
var solution := "" ## Stores the letters needed for the solution in the order they will be used
var solution_long := [] ## Stores solution in words instead of just letters

var current_game_version := "v0.21b"

var current_level := 0

# Settings Varibles
var screenShakeOn = true


func _ready() -> void:
	randomize()
	FileManager.load_game()

	await PostHog.initialized
	PostHog.auto_include_properties["distribution_platform"] = "itchio"
	PostHog.auto_include_properties["game_version"] = current_game_version
	PostHog.capture("GAME_START")


## Populates GameManagers level varibles with the new level data
## Returns true if level_num is a valid level, and everything is updated accordingly
func load_level(level_num) -> bool:
	if level_num <= len(LevelDatabase.levels) - 1:
		var next_level := LevelDatabase.levels[level_num]

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
	get_tree().change_scene_to_file("res://_Frames/level_select.tscn")

func start_game():
	load_level(current_level)
	get_tree().change_scene_to_file("res://_GameFrame/game.tscn")


func back_to_menu():
	get_tree().change_scene_to_file("res://_Frames/menu.tscn")
