extends Node

var dictoinary = ""
var words : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dictoinary = load_dictionary()
	words = dictoinary.split("\n", false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if words.is_empty():
		dictoinary = load_dictionary()
		words = dictoinary.split("\n", false)

## checks if word is in the dictionary
func is_legal_word(word : String) -> bool:
	return word.to_lower() in words

## load the dictionary
func load_dictionary():
	var file_path = "res://Globals/dictionary/12dicts_words.txt"
	var file = FileAccess.open(file_path, FileAccess.READ)
	#var file = ResourceLoader.load(file_path)
	
	if file:
		var file_content = file.get_as_text()
		return file_content
	else:
		push_warning("Failed to load dictioary")
		return null
