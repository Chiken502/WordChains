extends TextureButton


@export var level : int = 1:
	set(value):
		level = value
		$Label.text = str(value)


func _on_mouse_entered() -> void:
	if not disabled:
		var tween = get_tree().create_tween()

		tween.tween_property(self, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)


func _on_mouse_exited() -> void:
	if not disabled:
		var tween = get_tree().create_tween()

		tween.tween_property(self, "offset_transform_scale", Vector2(1, 1), 0.1)


func _on_button_down() -> void:
	if not disabled:
		var tween = get_tree().create_tween()

		tween.tween_property(self, "offset_transform_scale", Vector2(0.8, 0.8), 0.1)


func _on_button_up() -> void:
	if not disabled:
		var tween = get_tree().create_tween()

		tween.tween_property(self, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)
