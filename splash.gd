extends Control


func _on_animated_sprite_2d_animation_finished() -> void:
	MusicManager.start_music()
	GameManager.back_to_menu()
