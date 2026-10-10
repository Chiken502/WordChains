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

var loading : bool = false:
	set(value):
		loading = value
		$ProgressBar.visible = value
		if loading:
			$VBoxContainer.hide()
			$ProgressBar.fill_mode = ProgressBar.FillMode.FILL_BEGIN_TO_END
			$ProgressBar.value = 0
			start_loading()
		else:
			stop_loading()
			$VBoxContainer.show()

var _tween : Tween = null

func start_loading():
	_tween = get_tree().create_tween().set_loops()
	_tween.tween_property($ProgressBar, "value", 100, 0.75)
	_tween.tween_callback($ProgressBar.set_fill_mode.bind(ProgressBar.FillMode.FILL_END_TO_BEGIN)).set_delay(0.5)
	_tween.tween_property($ProgressBar, "value", 0, 0.75)
	_tween.tween_callback($ProgressBar.set_fill_mode.bind(ProgressBar.FillMode.FILL_BEGIN_TO_END)).set_delay(0.5)

func stop_loading():
	if _tween:
		_tween.stop()
		_tween.kill()
