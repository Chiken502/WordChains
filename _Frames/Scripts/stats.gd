extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FileManager.save_game()

	$VBoxContainer/PuzzlesCompleted/Label2.text = str(get_total_puzzles_completed())
	$VBoxContainer/DailysCompleted/Label2.text = str(GameManager.daily_puzzles_completed)
	$VBoxContainer/TimedModesCompleted/Label2.text = str(
		GameManager.total_timed_mode_puzzles_completed
	)
	$VBoxContainer/BestTimedMode/Label2.text = str(GameManager.best_timed_mode)
	$VBoxContainer/HintsUsed/Label2.text = str(GameManager.total_hints_used)
	$VBoxContainer/UndosUsed/Label2.text = str(GameManager.total_undos_used)
	$VBoxContainer/LettersDraged/Label2.text = str(GameManager.total_letters_dragged)

	for control in [
		%Home,
		%PuzzlesCompleted,
		%DailysCompleted,
		%TimedModesCompleted,
		%BestTimedMode,
		%HintsUsed,
		%UndosUsed,
		%LettersDraged,
		%Title,
	]:
		control.mouse_entered.connect(_on_control_mouse_entered.bind(control))
		control.mouse_exited.connect(_on_control_mouse_exited.bind(control))

	%Home.button_up.connect(_on_button_up.bind(%Home))
	%Home.button_down.connect(_on_button_down.bind(%Home))


func get_total_puzzles_completed():
	var total = 0
	for i in GameManager.current_levels:
		total += i

	return total


func _on_home_pressed() -> void:
	GameManager.back_to_menu()


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
