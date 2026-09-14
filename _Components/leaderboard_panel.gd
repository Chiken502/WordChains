extends Control


var rank := 1:
	set(value):
		rank = value

var nickname := "":
	set(value):
		nickname = value
		$HBoxContainer/Name.text = str(rank) + ". " + value

var seconds := 0:
	set(value):
		seconds = value
		$HBoxContainer/Time.text = str(floor(seconds / 60)) + ":" + str(seconds % 60).pad_zeros(2)
