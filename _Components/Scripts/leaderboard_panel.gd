extends Control

var rank := 1:
	set(value):
		rank = value

var nickname := "":
	set(value):
		nickname = value
		$HBoxContainer/Name.text = str(rank) + ". " + value

var time : int = 0:
	set(value):
		time = value

		var minutes := int(floor(time / 600.0))
		var seconds := int(floor((time % 600)) / 10.0)
		var tenths := time % 10

		$HBoxContainer/Time.text = "%d:%02d.%d" % [
			minutes,
			seconds,
			tenths
		]


func _on_mouse_entered() -> void:
	var tween = get_tree().create_tween()

	tween.tween_property(self, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)


func _on_mouse_exited() -> void:
	var tween = get_tree().create_tween()

	tween.tween_property(self, "offset_transform_scale", Vector2(1, 1), 0.1)
