extends Control

var level_select_node = preload("res://_Components/level_select_button.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for idx in range(len(LevelDatabase.levels)):
		var i :TextureButton = level_select_node.instantiate()
		$VBoxContainer/GridContainer.add_child(i)
		i.level = idx + 1
		$ColorAgent.texture_buttons.append(i)
		i.pressed.connect(_level_selected.bind(idx))
	
	ColorManager.change_color(ColorManager.currentColor)


func _on_home_pressed() -> void:
	GameManager.back_to_menu()


func _level_selected(level:int):
	GameManager.current_level = level
	GameManager.start_game()
