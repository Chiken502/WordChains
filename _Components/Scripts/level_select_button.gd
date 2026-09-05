extends TextureButton


@export var level : int = 1:
	set(value):
		level = value
		$Label.text = str(value)
