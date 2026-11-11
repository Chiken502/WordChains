extends Control

enum {OPEN, CLOSED, ANIMATING}
var state = CLOSED

var current_langauge = "EN"
var other_langauges = ["EN", "ES", "DE", "FR"]

var active_tweens : Array[Tween] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button in [$VBoxContainer/Main, $VBoxContainer/Button2, $VBoxContainer/Button3, $VBoxContainer/Button4]:
		button.mouse_entered.connect(_on_control_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_control_mouse_exited.bind(button))
		button.button_up.connect(_on_button_up.bind(button))
		button.button_down.connect(_on_button_down.bind(button))
	
	current_langauge = DictionaryManager.current_dict
	other_langauges[other_langauges.find(current_langauge)] = "EN"
	other_langauges[0] = current_langauge
	
	var buttons := $VBoxContainer.get_children()
	for i in range(buttons.size()):
		var texture_rect : TextureRect= buttons[i].get_children()[0].get_children()[0]
		texture_rect.texture = load("res://Flags/%s.png" % other_langauges[i])
		if i>0:
			buttons[i].offset_transform_scale = Vector2(0, 0)
			buttons[i].pressed.connect(_change_langauge.bind(i, texture_rect))
			buttons[i].disabled = true


func _clear_tweens() -> void:
	for tween in active_tweens:
		if tween and tween.is_valid():
			tween.kill()
	
	active_tweens.clear()


func expand():
	_clear_tweens()
	state = ANIMATING

	var buttons : Array = $VBoxContainer.get_children()
	for i in range(1, buttons.size()):
		var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
		active_tweens.append(tween)
		tween.tween_property(buttons[i], "offset_transform_scale", Vector2.ONE, 0.5)
		await get_tree().create_timer(0.2).timeout
	
	for i in range(1, buttons.size()):
		buttons[i].disabled = false
	
	await get_tree().create_timer(0.2).timeout
	state = OPEN


func contract():
	_clear_tweens()
	state = ANIMATING
	
	var buttons: Array = $ VBoxContainer.get_children()
	for i in range(buttons.size() -1, 0, -1):
		buttons[i].offset_transform_scale = Vector2(0, 0)
	
	for i in range(1, buttons.size()):
		buttons[i].disabled = true
	state = CLOSED


func _on_button_pressed() -> void:
	if state == CLOSED:
		expand()
	elif state == OPEN: 
		contract()


func _change_langauge(index: int, texture_rext: TextureRect):
	var new_lang = other_langauges[index]
	var old_lang = current_langauge
	
	other_langauges[index] = old_lang
	other_langauges[0] = new_lang
	
	texture_rext.texture = load("res://Flags/%s.png" % current_langauge)
	
	current_langauge = new_lang
	DictionaryManager.change_dictionary(new_lang)
	FileManager.save_game()
	
	$VBoxContainer/Main/PanelContainer/TextureRect.texture = load("res://Flags/%s.png" % current_langauge)
	
	contract()


# Animations 
func _on_control_mouse_entered(button: Button) -> void:
	if not button.disabled:
		var tween = get_tree().create_tween()

		tween.tween_property(button, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)


func _on_control_mouse_exited(button: Button) -> void:
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
