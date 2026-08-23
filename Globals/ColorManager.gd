extends Node

signal color_changed(oldColors: Array) ## Notifys listeners when the color has been changed

var currentColor := 0

var colors := [
	["Blue", "3A86FF", "72B0FD", "96D8FE"],
	["Purple", "8338EC", "AD72F1", "DCA0F3"],
	["Orange", "FB5607", "FD9A48", "FED496"],
	["Yellow", "FFBE0B", "FEE767", "FEF8BA"],
	["Red", "FF006E", "FD5C84", "FE9AAC"],
	["Black", "18003C", "403255", "837992"]
]


func get_color_idx(color_name : String) -> int:
	for i in range(len(colors)):
		if colors[i][0] == color_name:
			return i
	
	return 0 # defult to blue


## Changes colors in the main theme for the game.
func change_color(color_idx: int):
	if color_idx >= 0 and color_idx < colors.size(): # Check if its a legal color
		var oldColors : Array = colors[currentColor].duplicate()
		oldColors.remove_at(0) # Removes color name
		currentColor = color_idx
		
		var theme = preload("res://Resources/main_theme.tres")
		
		# Search through each theme type like: Button, Hslider ect
		for theme_type in theme.get_type_list():
			var color_list = theme.get_color_list(theme_type)
			for prop_name in color_list:
				var prop_color_idx = _color_in_array(oldColors, theme.get_color(prop_name, theme_type))
				
				if prop_color_idx != -1: # Swaps the colors, based on index values
					theme.set_color(prop_name, theme_type, Color(colors[currentColor][prop_color_idx + 1]))
			
			var stylebox_list = theme.get_stylebox_list(theme_type)
			for stylebox_name in stylebox_list:
				var style_box := theme.get_stylebox(stylebox_name, theme_type).duplicate()
				
				if style_box is StyleBoxFlat:
					var bg_idx = _color_in_array(oldColors, style_box.bg_color)
					
					var border_idx = _color_in_array(oldColors, style_box.border_color)
					
					if bg_idx != -1:
						style_box.bg_color = Color(colors[currentColor][bg_idx + 1])
					
					if border_idx != -1:
						style_box.border_color = Color(colors[currentColor][border_idx + 1])
					
					theme.set_stylebox(stylebox_name, theme_type, style_box)
			
			if theme_type != "OptionButton": # Modifys all icons exept for option button icons
				for icon_name in theme.get_icon_list(theme_type):
					var icon_path = "res://Resources/" + icon_name +".svg"
					
					theme.set_icon(icon_name, theme_type, modify_svg(icon_path))
		
		# Modifys colors of label settings
		for label_settings: LabelSettings in [preload("res://Resources/settings_label.tres"), preload("res://Resources/header_label.tres")]:
			var font_color_idx = _color_in_array(oldColors, label_settings.font_color)
			
			var outline_color_idx = _color_in_array(oldColors, label_settings.outline_color)
			
			if font_color_idx != -1:
				label_settings.font_color = Color(colors[currentColor][font_color_idx + 1])
			
			if outline_color_idx != -1:
				label_settings.outline_color = Color(colors[currentColor][outline_color_idx + 1])
		
		color_changed.emit(oldColors)

## opens a svg icon file and changes the colors. Returns the svg string
func modify_svg(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open SVG file.")
		return
	
	var svg_txt = file.get_as_text()
	file.close()
	
	var stroke_txt_idx = []
	var last_stroke_txt_idx = 0
	for _i in range(svg_txt.count('stroke="#')): # gets all the stroke colors idx sports
		var idx = svg_txt.find('stroke="#', last_stroke_txt_idx+1)
		last_stroke_txt_idx = idx
		if idx != -1:
			stroke_txt_idx.append(idx)
	
	var stroke_colors = []
	for idx in stroke_txt_idx: # gets all the stroke color codes from the idx's 
		var substring = svg_txt.substr(idx+9, 6)
		stroke_colors.append(substring)
	
	
	var fill_txt_idx = []
	var last_fill_txt_idx = 0
	for _j in range(svg_txt.count('fill="#')):
		var idx = svg_txt.find('fill="#', last_fill_txt_idx+1)
		last_fill_txt_idx = idx
		if idx != -1:
			fill_txt_idx.append(idx)
	
	var fill_colors = []
	for idx in fill_txt_idx:
		var substring = svg_txt.substr(idx+7, 6)
		fill_colors.append(substring)
	
	var modified_svg = svg_txt
	
	for i in range(len(fill_colors)): # Swaps any colors that are in the original color array
		var fill_color_idx = -1
		
		if fill_colors:
			fill_color_idx = _color_in_array(["3A86FF", "72B0FD", "96D8FE"], Color(fill_colors[i]))
		
		if fill_color_idx != -1:
			modified_svg = modified_svg.replace("#"+fill_colors[i], "#"+colors[currentColor][fill_color_idx + 1])
	
	for i in range(len(stroke_colors)):
		var stroke_color_idx = -1
		
		if stroke_colors:
			stroke_color_idx = _color_in_array(["3A86FF", "72B0FD", "96D8FE"], Color(stroke_colors[i]))
		
		if stroke_color_idx != -1:
			modified_svg = modified_svg.replace("#"+stroke_colors[i], "#"+colors[currentColor][stroke_color_idx + 1])
	
	
	
	var img = Image.new()
	# The second argument determines the rendering scale (1.0 = native size)
	var error = img.load_svg_from_string(modified_svg, 1.0) # create the new svg image
	
	if error == OK:
		var new_texture = ImageTexture.create_from_image(img)
		return new_texture
	else:
		push_error("Failed to parse modified SVG string.")
		return


## finds the color int the array and returns the index
func _color_in_array(array: Array, color : Color) -> int:
	var idx = -1
	for i in range(len(array)):
		if color.is_equal_approx(Color(array[i])):
			idx = i
			break
	
	return idx
