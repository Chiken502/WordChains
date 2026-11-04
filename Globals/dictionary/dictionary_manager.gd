extends Node

var current_dict = "EN"
var words: Dictionary # Using a Dictionary for O(1) lookup speads for is_legal_word
var words_loaded = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_dictionary()


## Checks if word is in the dictionary
func is_legal_word(word: String) -> bool:
	if not words_loaded:
		return false
	return words.has(word.strip_edges().to_lower())


## Load the dictionary
func load_dictionary():
	words_loaded = false
	words.clear()
	
	var file_path = "res://Globals/dictionary/%sdict.txt" % current_dict
	var file = FileAccess.open(file_path, FileAccess.READ)
	#var file = ResourceLoader.load(file_path)
	if not file:
		push_warning("Failed to load dictionary")
		return
	
	var file_content = file.get_as_text().replace("\r\n", "\n").replace("\r", "\n")
	var raw_words := file_content.split("\n", false)
	for w in raw_words:
		var clean_w := w.strip_edges().to_lower()
		if clean_w != "":
			words[clean_w] = true # True is place holder
	
	words_loaded = true

func change_dictionary(code: String):
	var old_dict = current_dict
	print("Changing Dict to: " + code)
	current_dict = code
	
	load_dictionary()
	
	GameManager.change_dicts(old_dict, current_dict)
