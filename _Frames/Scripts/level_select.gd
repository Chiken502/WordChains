extends Control

var level_select_node = preload("res://_Components/level_select_button.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for idx in range(len(LevelDatabase.levels)):
		var i: TextureButton = level_select_node.instantiate()
		$VBoxContainer/GridContainer.add_child(i)
		i.level = idx + 1
		$ColorAgent.texture_buttons.append(i)
		i.pressed.connect(_level_selected.bind(idx))

	ColorManager.change_color(ColorManager.currentColor)

	$VBoxContainer/Title.mouse_entered.connect(_on_control_mouse_entered.bind($VBoxContainer/Title))
	$VBoxContainer/Title.mouse_exited.connect(_on_control_mouse_exited.bind($VBoxContainer/Title))

	%Home.mouse_entered.connect(_on_control_mouse_entered.bind(%Home))
	%Home.mouse_exited.connect(_on_control_mouse_exited.bind(%Home))
	%Home.button_down.connect(_on_button_down.bind(%Home))
	%Home.button_up.connect(_on_button_up.bind(%Home))


func _on_home_pressed() -> void:
	GameManager.back_to_menu()


func _level_selected(level: int):
	GameManager.current_level = level
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
