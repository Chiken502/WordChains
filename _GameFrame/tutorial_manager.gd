extends Node2D

var sprite : Sprite2D

var hand_texture : ImageTexture
var closed_hand_texture : ImageTexture

var tween : Tween

var example_letter : RigidBody2D
var letters = []

func get_ready(start_signal : Signal):
	sprite = Sprite2D.new()
	hand_texture = ColorManager.modify_svg("res://Resources/hand.svg.txt")
	closed_hand_texture = ColorManager.modify_svg("res://Resources/hand-back-fist.svg.txt")
	
	sprite.texture = hand_texture
	sprite.modulate = Color.TRANSPARENT
	
	add_child(sprite)
	
	await start_signal
	
	await get_tree().create_timer(1).timeout
	
	for child in get_parent().get_children():
		if child.is_in_group("falling letter"):
			letters.append(child)
	
	var target_letter : String = GameManager.solution[0]
	for letter in letters:
		if letter.letter == target_letter:
			example_letter = letter
			break
	
	
	var idx = GameManager.solution_long.find(GameManager.current_word)
	var next_word = GameManager.solution_long[idx + 1]

	var letter_idx = -1
	for i in range(len(next_word)):
		if GameManager.current_word[i] == next_word[i]:
			pass
		else:
			letter_idx = i
			break
	
	var word_letter_label : Label = get_parent().get_node("Control/VBoxContainer/CurrentWordHBox").get_children()[letter_idx]
	
	await get_tree().create_timer(0.5).timeout
	
	var letter_starting_pos = example_letter.global_position
	
	var tween_to_pos = word_letter_label.global_position + (word_letter_label.size / 2)
	
	sprite.global_position = example_letter.global_position + Vector2(20, -30)
	sprite.rotation = - PI /3
	
	tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.5)
	tween.tween_await(get_tree().create_timer(1).timeout)
	tween.set_parallel()
	tween.tween_callback(func ():
		sprite.texture = closed_hand_texture
	)
	
	tween.tween_property(example_letter, "global_position", tween_to_pos, 1)
	tween.tween_property(sprite, "global_position", tween_to_pos + Vector2(20, -30), 1)
	tween.set_parallel(false)
	tween.tween_callback(func ():
		sprite.texture = hand_texture
		if example_letter:
			example_letter.global_position = letter_starting_pos)
	tween.tween_property(sprite, "modulate", Color.TRANSPARENT, 0.5)
	
	tween.tween_callback(func ():
		sprite.queue_free())
