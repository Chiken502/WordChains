extends Control

var expanded = false

var current_langauge = "EN"
var other_langauges = ["EN", "ES", "DE", "FR"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func expand():
	var buttons : Array = $VBoxContainer.get_children()
	for i in range(1, buttons.size()):
		var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(buttons[i], "offset_transform_scale", Vector2.ONE, 0.5)
		await get_tree().create_timer(0.2).timeout
	
	for i in range(1, buttons.size()):
		buttons[i].disabled = false
	expanded = true


func contract():
	var buttons: Array = $ VBoxContainer.get_children()
	for i in range(buttons.size() -1, 0, -1):
		buttons[i].offset_transform_scale = Vector2(0, 0)
	
	for i in range(1, buttons.size()):
		buttons[i].disabled = true
	expanded = false


func _on_button_pressed() -> void:
	if !expanded:
		expand()
	else: 
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
