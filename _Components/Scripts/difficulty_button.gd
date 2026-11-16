extends Button

## Difficulty level the button represents
@export var difficulty = 1:
	set(value):
		difficulty = value
		$Control/Stars.text = "Star".repeat(difficulty)
		$Level.text = tr("GAME_LEVEL") + " " + str(GameManager.progress[DictionaryManager.current_dict]["levelProg"][difficulty - 1] + 1)
		match difficulty:
			1:
				$Control/Difficulty.text = tr("GAME_EASY_MODE")
			2:
				$Control/Difficulty.text = tr("GAME_MEDIUM_MODE")
			3:
				$Control/Difficulty.text = tr("GAME_HARD_MODE")
			4:
				$Control/Difficulty.text = tr("GAME_EXPERT_MODE")
