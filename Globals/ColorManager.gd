extends Node

signal color_changed(old_colors: Array) ## Notify's listeners when the color has been changed

# Starts as the idx of Blue, 
# as blue is the base color that color manager uses to create all the others.
var current_color := 5 

var colors := [
	["Red", "FF006E", "FD5C84", "FE9AAC"],
	["Orange", "FB5607", "FD9A48", "FED496"],
	["Yellow", "FFBE0B", "FEE767", "FEF8BA"],
	["Green", "03D52D", "15E902", "9DFF5B"],
	["Teal", "3AD8FF", "72E8FD", "96FEF0"],
	["Blue", "3A86FF", "72B0FD", "96D8FE"],
	["Purple", "8338EC", "AD72F1", "DCA0F3"],
	["Black", "18003C", "403255", "837992"],
]

## Gets the index from ColorManagers.colors that has the same name as color_name.
## Returns the index for BLUE if color_name wasn't found.
func get_color_idx(color_name: String) -> int:
	for i in range(len(colors)):
		if colors[i][0] == color_name:
			return i

	return 5 # default to blue


## Changes colors in the main theme for the game to the color at ColorManager.colors[color_idx].
func change_color(color_idx: int):
	if color_idx >= 0 and color_idx < colors.size(): # Check if its a legal color
		var old_colors: Array = colors[current_color].duplicate()
		old_colors.remove_at(0) # Removes color name
		current_color = color_idx

		var theme = preload("res://Resources/main_theme.tres")

		# Search through each theme type like: Button, H-slider ect
		for theme_type in theme.get_type_list():
			var color_list = theme.get_color_list(theme_type)
			for prop_name in color_list:
				var prop_color_idx = color_in_array(
					old_colors,
					theme.get_color(prop_name, theme_type),
				)

				if prop_color_idx != -1: # Swaps the colors, based on index values
					theme.set_color(
						prop_name,
						theme_type,
						Color(colors[current_color][prop_color_idx + 1]),
					)

			# Change colors in style boxes
			var stylebox_list = theme.get_stylebox_list(theme_type)
			for stylebox_name in stylebox_list:
				var style_box := theme.get_stylebox(stylebox_name, theme_type).duplicate()

				if style_box is StyleBoxFlat:
					var bg_idx = color_in_array(old_colors, style_box.bg_color)

					var border_idx = color_in_array(old_colors, style_box.border_color)

					if bg_idx != -1:
						style_box.bg_color = Color(colors[current_color][bg_idx + 1])

					if border_idx != -1:
						style_box.border_color = Color(colors[current_color][border_idx + 1])

					theme.set_stylebox(stylebox_name, theme_type, style_box)

			if theme_type != "OptionButton": # Modifys all icons except for option button icons
				for icon_name in theme.get_icon_list(theme_type):
					var icon_path = "res://Resources/" + icon_name + ".svg.txt"

					theme.set_icon(icon_name, theme_type, modify_svg(icon_path))

		# Modifys colors of label settings
		for label_settings: LabelSettings in [
			preload("res://Resources/settings_label.tres"),
			preload("res://Resources/header_label.tres"),
			preload("res://Resources/level_select_label.tres"),
			preload("res://Resources/difficulty_title_label.tres"),
			preload("res://Resources/difficulty_stars_label.tres"),
			preload("res://Resources/difficulty_level_label.tres"),
		]:
			var font_color_idx = color_in_array(old_colors, label_settings.font_color)

			var outline_color_idx = color_in_array(old_colors, label_settings.outline_color)

			if font_color_idx != -1:
				label_settings.font_color = Color(colors[current_color][font_color_idx + 1])

			if outline_color_idx != -1:
				label_settings.outline_color = Color(colors[current_color][outline_color_idx + 1])

		color_changed.emit(old_colors)


## Opens a svg icon file and changes the colors. Returns the new Image Texture
func modify_svg(path: String) -> ImageTexture:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open SVG file.")
		return

	var svg_txt = file.get_as_text()
	file.close()

	var modified_svg = svg_txt

	modified_svg = modified_svg.replace("3A86FF", colors[current_color][1])
	modified_svg = modified_svg.replace("72B0FD", colors[current_color][2])
	modified_svg = modified_svg.replace("96D8FE", colors[current_color][3])

	var img = Image.new()
	# The second argument determines the rendering scale (1.0 = native size)
	var error = img.load_svg_from_string(modified_svg, 1.0) # create the new svg image
	if error == OK:
		var new_texture = ImageTexture.create_from_image(img)
		return new_texture
	push_error("Failed to parse modified SVG string.")
	return


## Finds the color int the array and returns the index.
## Returns -1 if the color wasn't found.
func color_in_array(array: Array, color: Color) -> int:
	var idx = -1
	for i in range(len(array)):
		if color.is_equal_approx(Color(array[i])):
			idx = i
			break

	return idx
