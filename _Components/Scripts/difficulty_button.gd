extends Button

## Difficulty level the button represents
@export var difficulty = 1:
	set(value):
		difficulty = value
		$Control/Stars.text = "Star".repeat(difficulty)
		$Level.text = "Level " + str(GameManager.current_levels[difficulty - 1] + 1)
		match difficulty:
			1:
				$Control/Difficulty.text = "EASY"
			2:
				$Control/Difficulty.text = "MEDIUM"
			3:
				$Control/Difficulty.text = "HARD"
			4:
				$Control/Difficulty.text = "EXPERT"
