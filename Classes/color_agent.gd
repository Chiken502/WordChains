extends Node
class_name ColorAgent

@export var bg_color_rect: ColorRect ## The backgroung ColorRect
@export var ground_color_rect: ColorRect ## The ground ColorRect

@export var labels: Array[Label] ## Labels that need color changes. A label dons't need to be in this list if it uses a saved LabelSetting
@export var texture_buttons: Array[TextureButton]

var orgColors := ["3A86FF", "72B0FD", "96D8FE"]


func _ready() -> void: # Changes colors of scene at the start to match ColorManager's current color
	ColorManager.color_changed.connect(_on_colors_changed)

	_on_colors_changed(orgColors)


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

	for button in texture_buttons:
		var normal_texture: GradientTexture2D = button.texture_normal
		var normal_gradient = normal_texture.gradient
		var normal_colors: PackedColorArray = normal_gradient.colors
		for idx in range(len(normal_colors)):
			var color = Color(normal_colors[idx], 1.0)
			var color_idx = ColorManager._color_in_array(orgColors, color)
			if color_idx != -1:
				normal_colors[idx] = Color(
					ColorManager.colors[ColorManager.currentColor][color_idx + 1],
					normal_colors[idx].a,
				)
		normal_gradient.colors = normal_colors

		var pressed_texture: GradientTexture2D = button.texture_pressed
		var pressed_gradient = pressed_texture.gradient
		var pressed_colors: PackedColorArray = pressed_gradient.colors
		for idx in range(len(pressed_colors)):
			var color = Color(pressed_colors[idx], 1.0)
			var color_idx = ColorManager._color_in_array(orgColors, color)
			if color_idx != -1:
				pressed_colors[idx] = Color(
					ColorManager.colors[ColorManager.currentColor][color_idx + 1],
					pressed_colors[idx].a,
				)
		pressed_gradient.colors = pressed_colors

		var hover_texture: GradientTexture2D = button.texture_hover
		var hover_gradient = hover_texture.gradient
		var hover_colors: PackedColorArray = hover_gradient.colors
		for idx in range(len(hover_colors)):
			var color = Color(hover_colors[idx], 1.0)
			var color_idx = ColorManager._color_in_array(orgColors, color)
			if color_idx != -1:
				hover_colors[idx] = Color(
					ColorManager.colors[ColorManager.currentColor][color_idx + 1],
					hover_colors[idx].a,
				)
		hover_gradient.colors = hover_colors
