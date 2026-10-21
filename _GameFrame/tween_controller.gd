extends Node2D

signal tween_done

@onready var word_container = $"../Control/Control2/VBoxContainer"
@onready var current_word_container = $"../Control/Control2/VBoxContainer/CurrentWordHBox"
@onready var wrong_word_label = $"../Control/Control2/VBoxContainer/WrongWord"

var not_a_word_tween: Tween

var inactive: bool = false:
	set(value):
		if inactive == value: # AVoid unessary tweens being called
			return

		inactive = value
		if inactive:
			inactive_tween = get_tree() \
					.create_tween() \
					.set_loops(100) \
					.set_ease(Tween.EASE_IN) \
					.set_trans(Tween.TRANS_SINE)
			inactive_tween.tween_property(%Hint, "self_modulate", Color(Color.WHITE, 0.5), 1).set_delay(
				0.1
			)
			inactive_tween.tween_property(%Hint, "self_modulate", Color.WHITE, 1).set_delay(0.5)
		else:
			inactive_tween.kill()
			%Hint.self_modulate = Color.WHITE

var inactive_tween: Tween


func _ready():
	for button in [%Undo, %LevelSelect, %Hint, %Reset]: # Connects button signals for animations
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
		button.button_up.connect(_on_button_up.bind(button))
		button.button_down.connect(_on_button_down.bind(button))


## Slides target words back onto screen.
func slide_in(size: Vector2):
	var tween = get_tree().create_tween()

	word_container.offset_transform_position = Vector2(size.x / 2 + 200, 0)

	MusicManager.slide_sound()
	tween \
			.tween_property(word_container, "offset_transform_position", Vector2(0, 0), 0.75) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_ELASTIC)

	await tween.finished
	tween_done.emit()


## Slides target words offscreen
func slide_off(size: Vector2):
	var tween = get_tree().create_tween()

	MusicManager.slide_sound()
	tween \
			.tween_property(
		word_container,
		"offset_transform_position",
		Vector2(-size.x / 2 - 200, 0),
		0.75,
	) \
			.set_ease(Tween.EASE_IN) \
			.set_trans(Tween.TRANS_QUINT)

	await tween.finished
	tween_done.emit()


func hint_given():
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.set_parallel()
	
	tween.tween_property($"../Control/Bottom/HBoxContainer/Hint/Panel", "offset_transform_scale", Vector2(2, 2), 0.5)
	tween.tween_property($"../Control/Bottom/HBoxContainer/Hint/Panel/Label", "offset_transform_scale", Vector2(1.1, 1.1), 0.5)
	tween.chain()
	tween.tween_property($"../Control/Bottom/HBoxContainer/Hint/Panel", "offset_transform_scale", Vector2.ONE, 1.0).set_delay(1.0)
	tween.tween_property($"../Control/Bottom/HBoxContainer/Hint/Panel/Label", "offset_transform_scale", Vector2.ONE, 1.0).set_delay(1.0)


# Shakes the current words to indicate that its not a word
func not_a_word():
	if not_a_word_tween:
		not_a_word_tween.kill()
		not_a_word_tween = null
		wrong_word_label.modulate = Color.WHITE

	not_a_word_tween = get_tree().create_tween()

	var random_offset = Vector2(randf_range(0, 1), randf_range(0, 1)).normalized() * 5
	current_word_container.offset_transform_position = random_offset
	not_a_word_tween \
			.tween_property(current_word_container, "offset_transform_position", Vector2.ZERO, 0.5) \
			.set_trans(Tween.TRANS_ELASTIC) \
			.set_ease(Tween.EASE_IN_OUT)

	not_a_word_tween \
			.tween_property(wrong_word_label, "modulate", Color.TRANSPARENT, 1.0) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_SINE)

	await not_a_word_tween.finished
	wrong_word_label.text = ""
	wrong_word_label.modulate = Color.WHITE
	tween_done.emit()
	not_a_word_tween.kill()
	not_a_word_tween = null


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


func _on_reset_pressed() -> void:
	var tween = get_tree().create_tween()

	%Reset.offset_transform_rotation = 0
	tween.tween_property(%Reset, "offset_transform_rotation", PI, 0.5)
