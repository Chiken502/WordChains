extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !CheddaBoards.is_logged_in():
		CheddaBoards.login_anonymous()
		await CheddaBoards.login_success
	
	CheddaBoards.scoreboard_loaded.connect(_on_leaderboard)
	CheddaBoards.scoreboard_error.connect(func(error):print("score board error: " + str(error)))
	
	if (GameManager.daily_mode and !CheddaBoards.is_logged_in()) or CheddaBoards.get_nickname().strip_edges() == "":
		print("Nickname is \"" + CheddaBoards.get_nickname() + "\"")
		$VBoxContainer/VBoxContainer.show()
	else:
		$VBoxContainer/VBoxContainer.hide()
		$VBoxContainer/ScrollContainer/VBoxContainer2/Label.show()
		show_leaderboard()
		GameManager.daily_mode = false


func show_leaderboard():
	print("REQUESTING LEADERBOARD")
	CheddaBoards.get_scoreboard("daily-puzzle-times")
	print("GET_SCOREBOARD CALLED")

func _on_leaderboard(sb_id, config, entries):
	print("LEADERBOARD RECEIVED")
	$VBoxContainer/ScrollContainer/VBoxContainer2/Label.hide()
	for i in entries:
		print("ENTRY: ", i)
		
		var panel = preload("res://_Components/leaderboard_panel.tscn").instantiate()
		$VBoxContainer/ScrollContainer/VBoxContainer2.add_child(panel)
		panel.rank = int(i["rank"])
		panel.nickname = i["nickname"]
		panel.seconds = 3600 - i["score"]


func _on_button_pressed() -> void:
	if $VBoxContainer/VBoxContainer/LineEdit.text != "":
		CheddaBoards.login_anonymous($VBoxContainer/VBoxContainer/LineEdit.text)
		print("WAITING FOR LOGIN")

		await CheddaBoards.login_success

		print("LOGIN FINISHED")

		GameManager.nickname = $VBoxContainer/VBoxContainer/LineEdit.text
		FileManager.save_game()

		var score = maxi(0, 3600 - GameManager.daily_time)
		CheddaBoards.submit_score(score)
		
		$VBoxContainer/VBoxContainer.hide()
		$VBoxContainer/ScrollContainer/VBoxContainer2/Label.show()
		await CheddaBoards.score_submitted
		show_leaderboard()


func _on_home_pressed() -> void:
	GameManager.back_to_menu()
