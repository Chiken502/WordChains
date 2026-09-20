extends Control

var level_select_node = preload("res://_Components/level_select_button.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(4):
		var button : Button = preload("res://_Components/difficulty_button.tscn").instantiate()
		button.difficulty = i + 1
		$VBoxContainer/GridContainer.add_child(button)
		button.pressed.connect(_level_selected.bind(i))
		
		button.mouse_entered.connect(_on_control_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_control_mouse_exited.bind(button))
		button.button_up.connect(_on_button_up.bind(button))
		button.button_down.connect(_on_button_down.bind(button))
	
	
	ColorManager.change_color(ColorManager.currentColor)
	MusicManager.scene_loaded()

	$VBoxContainer/Title.mouse_entered.connect(_on_control_mouse_entered.bind($VBoxContainer/Title))
	$VBoxContainer/Title.mouse_exited.connect(_on_control_mouse_exited.bind($VBoxContainer/Title))

	%Home.mouse_entered.connect(_on_control_mouse_entered.bind(%Home))
	%Home.mouse_exited.connect(_on_control_mouse_exited.bind(%Home))
	%Home.button_down.connect(_on_button_down.bind(%Home))
	%Home.button_up.connect(_on_button_up.bind(%Home))

	%DailyButton.mouse_entered.connect(_on_control_mouse_entered.bind(%DailyButton))
	%DailyButton.mouse_exited.connect(_on_control_mouse_exited.bind(%DailyButton))
	%DailyButton.button_down.connect(_on_button_down.bind(%DailyButton))
	%DailyButton.button_up.connect(_on_button_up.bind(%DailyButton))

	if GameManager.daily_completed:
		%DailyButton.text = "View Daily Leaderboard"


func _on_home_pressed() -> void:
	GameManager.back_to_menu()


func _level_selected(difficulty: int):
	GameManager.load_level(difficulty, GameManager.current_levels[difficulty])
	GameManager.start_game()


func _on_control_mouse_entered(control: Control) -> void:
	var tween = get_tree().create_tween()

	tween.tween_property(control, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)


func _on_control_mouse_exited(control: Control) -> void:
	var tween = get_tree().create_tween()

	tween.tween_property(control, "offset_transform_scale", Vector2(1, 1), 0.1)


func _on_button_up(button: Button):
	if not button.disabled:
		var tween = get_tree().create_tween()

		tween.tween_property(button, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)


func _on_button_down(button: Button):
	if not button.disabled:
		var tween = get_tree().create_tween()

		tween.tween_property(button, "offset_transform_scale", Vector2(0.8, 0.8), 0.1)


func _on_daily_button_pressed() -> void:
	if GameManager.daily_completed:
		GameManager.open_leaderboard()
	else:
		$Panel.show()
		GameManager.load_daily_puzzle($Panel)
