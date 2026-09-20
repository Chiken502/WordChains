extends Control

var rank := 1:
	set(value):
		rank = value

var nickname := "":
	set(value):
		nickname = value
		$HBoxContainer/Name.text = str(rank) + ". " + value

var seconds := 0:
	set(value):
		seconds = value
		$HBoxContainer/Time.text = str(int(floor(seconds / 60.0))) + ":" \
		+ str(seconds % 60).pad_zeros(
			2
		)


func _on_mouse_entered() -> void:
	var tween = get_tree().create_tween()

	tween.tween_property(self, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)


func _on_mouse_exited() -> void:
	var tween = get_tree().create_tween()

	tween.tween_property(self, "offset_transform_scale", Vector2(1, 1), 0.1)
