extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void: # Connect signals for animations
	MusicManager.scene_loaded()
	
	%Home.mouse_entered.connect(_on_button_mouse_entered.bind(%Home))
	%Home.mouse_exited.connect(_on_button_mouse_exited.bind(%Home))
	%Home.button_up.connect(_on_button_up.bind(%Home))
	%Home.button_down.connect(_on_button_down.bind(%Home))


func _on_home_pressed() -> void:
	GameManager.back_to_menu()


# Button Animations
func _on_button_mouse_entered(button : Button) -> void:
	if not button.disabled:
		var tween = get_tree().create_tween()
		
		tween.tween_property(button, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)

func _on_button_mouse_exited(button : Button) -> void:
	if not button.disabled:
		var tween = get_tree().create_tween()
		
		tween.tween_property(button, "offset_transform_scale", Vector2(1,1), 0.1)

func _on_button_up(button : Button):
	if not button.disabled:
		var tween = get_tree().create_tween()
		
		tween.tween_property(button, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)

func _on_button_down(button : Button):
	if not button.disabled:
		var tween = get_tree().create_tween()
		
		tween.tween_property(button, "offset_transform_scale", Vector2(0.8, 0.8), 0.1)
