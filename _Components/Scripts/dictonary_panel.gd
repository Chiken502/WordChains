extends Control

var word : String = "Loading":
	set(value):
		word = value
		$VBoxContainer/Word.text = value

var definition : String = "(countable, uncountable) The process by which something is loaded.":
	set(value):
		definition = value
		$VBoxContainer/Deffinition.text = value
