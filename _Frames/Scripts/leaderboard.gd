extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.scene_loaded()
	
	# Connect Chedda Boards if not logged in already
	if !CheddaBoards.is_logged_in():
		CheddaBoards.login_anonymous()
		await CheddaBoards.login_success
	
	CheddaBoards.scoreboard_loaded.connect(_on_leaderboard)
	CheddaBoards.scoreboard_error.connect(func(error):print("score board error: " + str(error)))
	
	CheddaBoards.score_error.connect((func(error):print("score submit error: "+ str(error))))
	CheddaBoards.score_submitted.connect(
		(func(score, _streak):print("score submitted: " + str(score)))
	)
	
	# Show the correct UI, for wether you have a nickname yet or not
	if GameManager.nickname.strip_edges() == "" or CheddaBoards.get_nickname().strip_edges() == "":
		print("Nickname is \"" + CheddaBoards.get_nickname() + "\"")
		$VBoxContainer/VBoxContainer.show()
	else:
		if GameManager.daily_mode:
			var score = maxi(0, 36000 - GameManager.daily_time)
			CheddaBoards.submit_score(score)
			print("Submitting score")
		
		$VBoxContainer/VBoxContainer.hide()
		$VBoxContainer/ScrollContainer/VBoxContainer2/Label.show()
		show_leaderboard()
		GameManager.daily_mode = false
	
	# Connect Control Animations
	$VBoxContainer/Title.mouse_entered.connect(_on_control_mouse_entered.bind($VBoxContainer/Title))
	$VBoxContainer/Title.mouse_exited.connect(_on_control_mouse_exited.bind($VBoxContainer/Title))
	
	%Home.mouse_entered.connect(_on_control_mouse_entered.bind(%Home))
	%Home.mouse_exited.connect(_on_control_mouse_exited.bind($%Home))
	%Home.button_up.connect(_on_button_up.bind(%Home))
	%Home.button_down.connect(_on_button_down.bind($%Home))

## Fetches the leaderboard
func show_leaderboard():
	print("REQUESTING LEADERBOARD")
	CheddaBoards.get_scoreboard("daily-puzzle-times")
	print("GET_SCOREBOARD CALLED")

## Leader board request recived
func _on_leaderboard(_sb_id, _config, entries):
	print("LEADERBOARD RECEIVED")
	$VBoxContainer/ScrollContainer/VBoxContainer2/Label.hide()
	for i in entries:
		print("ENTRY: ", i)

		var panel: Control = preload("res://_Components/leaderboard_panel.tscn").instantiate()
		$VBoxContainer/ScrollContainer/VBoxContainer2.add_child(panel)
		panel.rank = int(i["rank"])
		panel.nickname = i["nickname"]
		panel.time = 36000 - i["score"]

		panel.offset_transform_scale = Vector2(1.2, 1.2)
		var tween = get_tree().create_tween()
		tween \
				.tween_property(panel, "offset_transform_scale", Vector2.ONE, 0.5) \
				.set_ease(Tween.EASE_OUT) \
				.set_trans(Tween.TRANS_QUINT)
		await tween.finished

# Nickname button pressed
func _on_button_pressed() -> void:
	if $VBoxContainer/VBoxContainer/LineEdit.text != "":
		CheddaBoards.login_anonymous($VBoxContainer/VBoxContainer/LineEdit.text)
		print("WAITING FOR LOGIN")

		await CheddaBoards.login_success

		print("LOGIN FINISHED")

		GameManager.nickname = $VBoxContainer/VBoxContainer/LineEdit.text
		FileManager.save_game()

		var score = maxi(0, 36000 - GameManager.daily_time)
		CheddaBoards.submit_score(score)

		$VBoxContainer/VBoxContainer.hide()
		$VBoxContainer/ScrollContainer/VBoxContainer2/Label.show()
		await CheddaBoards.score_submitted
		show_leaderboard()


func _on_home_pressed() -> void:
	GameManager.back_to_menu()


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

# Formats the line edit according rules in to 
# https://docs.cheddaboards.com/api/errors#nickname-rejected
func _on_line_edit_text_changed(new_text: String) -> void:
	var lineedit = $VBoxContainer/VBoxContainer/LineEdit
	var filtered := ""

	for character in new_text:
		if character in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_":
			filtered += character

	if filtered != new_text:
		var cursor_position: int = lineedit.caret_column
		lineedit.text = filtered
		lineedit.caret_column = min(cursor_position - 1, filtered.length())
