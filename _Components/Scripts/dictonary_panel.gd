extends Control

var word : String = "Loading":
	set(value):
		word = value
		$VBoxContainer/HBoxContainer/Word.text = value

var definition : String = "(countable, uncountable) The process by which something is loaded.":
	set(value):
		definition = value
		$VBoxContainer/Deffinition.text = value

var part_of_speech : String = "Noun":
	set(value):
		part_of_speech = value
		$VBoxContainer/HBoxContainer/PartSpeech.text = value
