extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void: # Connect signals for animations
	MusicManager.scene_loaded()
	for button in [%Settings, %Play, %Credits]:
		button.mouse_entered.connect(_on_control_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_control_mouse_exited.bind(button))
		button.button_up.connect(_on_button_up.bind(button))
		button.button_down.connect(_on_button_down.bind(button))
	
	$Title.mouse_entered.connect(_on_control_mouse_entered.bind($Title))
	$Title.mouse_exited.connect(_on_control_mouse_exited.bind($Title))


func _on_settings_pressed() -> void:
	GameManager.open_settings()


func _on_play_pressed() -> void:
	GameManager.start_game()


func _on_credits_pressed() -> void:
	GameManager.open_credits()


# Animations
func _on_control_mouse_entered(control : Control) -> void:
	var tween = get_tree().create_tween()
	
	tween.tween_property(control, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)

func _on_control_mouse_exited(control : Control) -> void:
	var tween = get_tree().create_tween()
	
	tween.tween_property(control, "offset_transform_scale", Vector2(1, 1), 0.1)

func _on_button_up(button : Button):
	if not button.disabled:
		var tween = get_tree().create_tween()
		
		tween.tween_property(button, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)

func _on_button_down(button : Button):
	if not button.disabled:
		var tween = get_tree().create_tween()
		
		tween.tween_property(button, "offset_transform_scale", Vector2(0.8, 0.8), 0.1)
