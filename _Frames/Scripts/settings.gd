extends Control

var music_bus_idx := AudioServer.get_bus_index("Music Bus")
var sound_bus_idx := AudioServer.get_bus_index("SFX Bus")

var sound_feedback_cooldown := 0.4
var last_sound_feedback: float

var settings_changed = false
var nickname_changed = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Version.text = GameManager.current_game_version

	MusicManager.scene_loaded()
	# Set up option buttons options
	for colors in ColorManager.colors:
		$VBoxContainer/Color/OptionButton.add_item(colors[0])

	$VBoxContainer/Color/OptionButton.selected = ColorManager.current_color

	# Connect signals for animations
	%Home.button_up.connect(_on_button_up.bind(%Home))
	%Home.button_down.connect(_on_button_down.bind(%Home))
	$VBoxContainer/ScreenShake/CheckBox.button_up.connect(
		_on_button_up.bind($VBoxContainer/ScreenShake/CheckBox)
	)
	$VBoxContainer/ScreenShake/CheckBox.button_down.connect(
		_on_button_down.bind($VBoxContainer/ScreenShake/CheckBox)
	)
	%TutorialButton.button_up.connect(_on_button_up.bind(%TutorialButton))
	%TutorialButton.button_down.connect(_on_button_down.bind(%TutorialButton))

	for control in [%Color, %Music, %Sound, %Home, %Title, %ScreenShake, %Nickname, %TutorialButton]:
		control.mouse_entered.connect(_on_control_mouse_entered.bind(control))
		control.mouse_exited.connect(_on_control_mouse_exited.bind(control))

	$VBoxContainer/ScreenShake/CheckBox.button_pressed = GameManager.screen_shake_on

	last_sound_feedback = Time.get_ticks_msec() / 1000.0 + 0.5

	$VBoxContainer/Music/HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_idx))
	$VBoxContainer/Sound/HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(sound_bus_idx))

	$VBoxContainer/Nickname/LineEdit.text = GameManager.nickname


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		PostHog.enabled = false


func _on_home_pressed() -> void:
	save_settings()
	GameManager.back_to_menu()


func save_settings():
	if nickname_changed:
		if !CheddaBoards.is_logged_in():
			CheddaBoards.login_anonymous()
			await CheddaBoards.login_success

		GameManager.nickname = $VBoxContainer/Nickname/LineEdit.text
		print(GameManager.nickname)
		CheddaBoards.change_nickname(GameManager.nickname)
		FileManager.save_game()
	if settings_changed:
		FileManager.save_settings()


# Animations
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


# Settings signals
func _on_option_button_item_selected(index: int) -> void:
	settings_changed = true
	ColorManager.change_color(index)


func _on_check_box_pressed() -> void:
	settings_changed = true
	GameManager.screen_shake_on = $VBoxContainer/ScreenShake/CheckBox.button_pressed


func _on_music_slider_value_changed(value: float) -> void:
	settings_changed = true
	AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(value))


func _on_sound_slider_value_changed(value: float) -> void:
	settings_changed = true
	AudioServer.set_bus_volume_db(sound_bus_idx, linear_to_db(value))
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_sound_feedback > sound_feedback_cooldown:
		last_sound_feedback = current_time
		MusicManager.sound_feedback_noise()


func _on_line_edit_text_changed(new_text: String) -> void:
	var lineedit = $VBoxContainer/Nickname/LineEdit
	var filtered := ""

	for character in new_text:
		if character in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_":
			filtered += character

	if filtered != new_text:
		var cursor_position: int = lineedit.caret_column
		lineedit.text = filtered
		lineedit.caret_column = min(cursor_position - 1, filtered.length())

	if filtered != GameManager.nickname:
		settings_changed = true
		nickname_changed = true
	else:
		settings_changed = false
		nickname_changed = false


func _on_replay_tutorial_button_pressed() -> void:
	save_settings()
	GameManager.need_tutorial = true
	GameManager.open_level_select()
