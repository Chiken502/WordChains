extends Node


func scene_loaded():
	print("Scene Loaded")
	for node in get_tree().current_scene.find_children("*", "", true, false):
		if node is BaseButton:
			node.pressed.connect(button_pressed)


func start_music():
	await get_tree().create_timer(0.5).timeout
	$MusicPlayer/MusicOpener.play()


func button_pressed():
	$ButtonPress.play()


func error_sound():
	$Error.play()


func connect_sound():
	$Connect.play()


func complete_sound():
	$Complete.play()


func slide_sound():
	$Slide.play()


func sound_feedback_noise():
	$SoundFeedback.play()


func _on_music_opener_finished() -> void:
	$MusicPlayer.play()
