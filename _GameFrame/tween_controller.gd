extends Node2D

signal tween_done

@onready var word_container = $"../Control/VBoxContainer"
@onready var current_word_container = $"../Control/VBoxContainer/CurrentWordHBox"


func _ready():
	for button in [%Undo, %Home, %Hint]: # Connects button signals for animations
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
		button.button_up.connect(_on_button_up.bind(button))
		button.button_down.connect(_on_button_down.bind(button))


## Slides target words back onto screen.
func slide_in():
	var tween = get_tree().create_tween()

	word_container.offset_transform_position = Vector2(400, 0)

	MusicManager.slide_sound()
	tween \
			.tween_property(word_container, "offset_transform_position", Vector2(0, 0), 0.75) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_ELASTIC)

	await tween.finished
	tween_done.emit()


## Slides target words offscreen
func slide_off():
	var tween = get_tree().create_tween()

	MusicManager.slide_sound()
	tween \
			.tween_property(word_container, "offset_transform_position", Vector2(-400, 0), 0.75) \
			.set_ease(Tween.EASE_IN) \
			.set_trans(Tween.TRANS_QUINT)

	await tween.finished
	tween_done.emit()


# Shakes the current words to indicate that its not a word
func not_a_word():
	var tween = get_tree().create_tween()

	current_word_container.offset_transform_position = Vector2(randf_range(0, 1), randf_range(0, 1)).normalized() * 5
	tween \
			.tween_property(current_word_container, "offset_transform_position", Vector2.ZERO, 0.5) \
			.set_trans(Tween.TRANS_ELASTIC) \
			.set_ease(Tween.EASE_IN_OUT)

	await tween.finished
	tween_done.emit()


# button animations
func _on_button_mouse_entered(button: Button) -> void:
	if not button.disabled:
		var tween = get_tree().create_tween()

		tween.tween_property(button, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)


func _on_button_mouse_exited(button: Button) -> void:
	if not button.disabled:
		var tween = get_tree().create_tween()

		tween.tween_property(button, "offset_transform_scale", Vector2(1, 1), 0.1)


func _on_button_up(button: Button):
	if not button.disabled:
		var tween = get_tree().create_tween()

		tween.tween_property(button, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)


func _on_button_down(button: Button):
	if not button.disabled:
		var tween = get_tree().create_tween()

		tween.tween_property(button, "offset_transform_scale", Vector2(0.8, 0.8), 0.1)
