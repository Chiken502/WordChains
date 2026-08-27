extends Node
class_name ColorAgent

@export var bg_color_rect: ColorRect ## The backgroung ColorRect
@export var ground_color_rect: ColorRect ## The ground ColorRect

@export var labels: Array[Label] ## Labels that need color changes. A label dons't need to be in this list if it uses a saved LabelSetting

var orgColors := ["3A86FF", "72B0FD", "96D8FE"]


func _ready() -> void: # Changes colors of scene at the start to match ColorManager's current color
	ColorManager.color_changed.connect(_on_colors_changed)

	bg_color_rect.color = ColorManager.colors[ColorManager.currentColor][3]
	ground_color_rect.color = ColorManager.colors[ColorManager.currentColor][1]

	for label in labels:
		var label_settings = label.label_settings

		var font_color_idx = ColorManager._color_in_array(orgColors, label_settings.font_color)
		var outline_color_idx = ColorManager._color_in_array(
			orgColors,
			label_settings.outline_color,
		)

		if font_color_idx != -1:
			label_settings.font_color = Color(
				ColorManager.colors[ColorManager.currentColor][font_color_idx + 1]
			)

		if outline_color_idx != -1:
			label_settings.outline_color = Color(
				ColorManager.colors[ColorManager.currentColor][outline_color_idx + 1]
			)


# recives color change from ColorManager, and changes colors in the current scene
func _on_colors_changed(oldColors):
	bg_color_rect.color = ColorManager.colors[ColorManager.currentColor][3]
	ground_color_rect.color = ColorManager.colors[ColorManager.currentColor][1]

	for label in labels: # Changes label settings colors
		var label_settings = label.label_settings

		var font_color_idx = ColorManager._color_in_array(oldColors, label_settings.font_color)
		var outline_color_idx = ColorManager._color_in_array(
			oldColors,
			label_settings.outline_color,
		)

		if font_color_idx != -1:
			label_settings.font_color = Color(
				ColorManager.colors[ColorManager.currentColor][font_color_idx + 1]
			)

		if outline_color_idx != -1:
			label_settings.outline_color = Color(
				ColorManager.colors[ColorManager.currentColor][outline_color_idx + 1]
			)
