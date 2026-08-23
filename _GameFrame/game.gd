extends Control

signal word_confirmed(letter_node, new_letter : String)
signal word_not_found(letter_node)

var starting_word : String
var target_word : String
var current_word : String
var solution = []
var solution_long := []
var shuffled

var undo_history :Array[String] = []

var hints := 0:
	set(value):
		hints = value
		$Control/Bottom/HBoxContainer/Hint/Panel/Label.text = str(value)

var completed = false

# Analytics
var level_start_time = 0.0
var hints_used = 0
var undo_used = 0

@onready var target_label := $Control/VBoxContainer/TargetWord
@onready var cw_h_box := $Control/VBoxContainer/CurrentWordHBox
@onready var undo_button := $Control/Bottom/HBoxContainer/Undo

@onready var tween_controler = $TweenController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.scene_loaded()
	get_ready()
	$Control/Bottom/HBoxContainer/Hint/Panel/Label.text = str(hints)

func get_ready():
	solution.clear()
	
	level_start_time = Time.get_ticks_msec()
	
	# Fetching level info from GameManager
	var solution_str = GameManager.solution
	for i in solution_str: # Converts solution from string to array
		solution.append(i.to_upper())
	
	solution_long = GameManager.solution_long
	
	starting_word = GameManager.starting_word
	GameManager.current_word = starting_word
	current_word = starting_word
	
	target_word = GameManager.target_word
	
	# reset varibles and Current letter nodes
	reset_self()
	
	completed = false
	undo_history = []
	
	target_label.text = target_word
	
	for i in range(len(starting_word)): # Spawning in current word letters
		var l : Label = preload("res://_Components/curent_word_letter.tscn").instantiate()
		cw_h_box.add_child(l)
		
		l.text = starting_word[i].to_upper()
		l.letter = starting_word[i].to_upper()
		
		
		l.letter_changed.connect(_on_current_word_letter_changed)
		word_confirmed.connect(l._on_word_confirmed)
		word_not_found.connect(l._on_word_not_found)
	
	hints += 1
	hints_used = 0
	undo_used = 0
	
	PostHog.capture("level_started", {"level" : GameManager.current_level + 1})
	
	# Animate words sliding on
	tween_controler.slide_in()
	await tween_controler.tween_done
	
	# Spawn falling letters
	spawn_letters()


func spawn_letters():
	shuffled = solution.duplicate() # duplicate to avoid shufling the original solution
	if solution is PackedStringArray:
		shuffled = Array(solution.duplicate())
	shuffled.shuffle()
	#print(shuffled)
	
	var letter_pos = []
	
	for l in shuffled: # Instantiate letters
		var letter = preload("res://_Components/falling_letter.tscn").instantiate()
		
		add_child(letter)
		letter.position = Vector2(randi_range(100, int(get_viewport_rect().size.x) - 100), -80)
		
		letter_pos = check_letter_position(letter_pos, letter) # Check if the letter is going to collide with another
		
		letter.letter = l
		letter.get_ready() 

# Made sure the letters didn't collide with each other
func check_letter_position(letter_pos: Array, letter: Node2D) -> Array:
	var min_x := 100
	var max_x := int(get_viewport_rect().size.x) - 100
	var y := -80
	
	while y > -1000:
		var possible_positions: Array[Vector2] = []
		
		# Check every possible X position at this Y
		for x in range(min_x, max_x + 1, 25):
			var new_position := Vector2(x, y)
			var safe := true
			
			for pos in letter_pos:
				var distance_x = abs(pos.x - new_position.x)
				var distance_y = abs(pos.y - new_position.y)
				
				# Make sure the new letter isn't too close
				if distance_x < 150 and distance_y < 100:
					safe = false
					break
			
			if safe:
				possible_positions.append(new_position)
		
		# If we found positions at this Y, pick one
		if not possible_positions.is_empty():
			var chosen_position = possible_positions.pick_random()
			
			letter.position = chosen_position
			letter_pos.append(chosen_position)
			
			return letter_pos
		
		# No X positions available, move 100 pixels upward
		y -= 100
	
	print("Couldn't find a safe position!")
	return letter_pos


func _on_current_word_letter_changed(node, letter):
	var index = cw_h_box.get_children().find(node)
	
	if index == -1:
		return
	
	var char = current_word.split("")
	if char[index] == letter:
		return
	char[index] = letter
	var new_word = "".join(char)
	
	#print(new_word)
	
	# Check if the word is in the dictionary
	if DictionaryManager.is_legal_word(new_word):
		undo_history.append(current_word) #save current before changing to save history for undo
		current_word = new_word
		GameManager.current_word = current_word
		word_confirmed.emit(node, letter)
		MusicManager.connect_sound()
		$Control/VBoxContainer/Hint.text = ""
	else:
		# Run animation
		if GameManager.screenShakeOn:
			$Control/CameraHolder/ShakeCamera2D.screen_shake(10, 0.75)
		
		$TweenController.not_a_word()
		word_not_found.emit(node) #TODO: ADD ERROR SOUND


func _process(_delta: float) -> void:
	if undo_history:
		undo_button.disabled = false
	else:
		undo_button.disabled = true
	
	if completed:
		undo_button.disabled = true
	
	if hints <= 0:
		%Hint.disabled = true
	else: 
		%Hint.disabled = false
	
	# Checks if puzzle is completed
	if current_word == target_word:
		if not completed:
			completed = true
			await get_tree().create_timer(1).timeout
			for child in cw_h_box.get_children():
				child.succses() 
			MusicManager.complete_sound()
			
			$Control/VBoxContainer/Hint.text = ""
			
			await get_tree().create_timer(1).timeout #TODO: ADD CHIME SOUND
			
			
			# animation
			tween_controler.slide_off()
			await tween_controler.tween_done
			
			var sucseces = GameManager.load_level(GameManager.current_level + 1)
			
			if sucseces:
				var level_time = (Time.get_ticks_msec() - level_start_time) / 1000.0
				
				PostHog.capture("level complete", {
					"level" : GameManager.current_level, 
					"time" : level_time, 
					"hints used" : hints_used,
					"undos used" : undo_used
					})
				get_ready()
			else: # Happens on the last level.
				print("Couldn't load level %s. Going Home" % str(GameManager.current_level + 1))
				
				PostHog.capture("GAME_COMPLETE")
				GameManager.current_level = 0
				GameManager.back_to_menu()



func _on_undo_button_pressed() -> void:
	if undo_history: #TODO: ADD UNDO SOUND?
		var prev_word = undo_history.pop_back() # pop_back removes and returns last value
		print(prev_word)
		
		var prev_char = prev_word.split("")
		var current_char = current_word.split("")
		
		var index : int
		
		
		for i in range(len(prev_char)):
			if prev_char[i] == current_char[i]:
				continue
			else:
				index = i
		
		var letter_node : Label = cw_h_box.get_children()[index]
		
		letter_node.text = prev_char[index]
		
		var letter_node_pos = letter_node.global_position + (letter_node.size / 2)
		
		var falling_letter = preload("res://_Components/falling_letter.tscn").instantiate()
		get_parent().add_child(falling_letter) # adds letter to main scene
		falling_letter.position = letter_node_pos
		falling_letter.letter = current_char[index]
		falling_letter.get_ready() # sets everything up
		
		letter_node.flash_undo()
		
		current_word = prev_word
		GameManager.current_word = current_word

func reset_self():
	for child in cw_h_box.get_children():
		child.queue_free()

func _on_home_button_pressed() -> void:
	GameManager.back_to_menu()

func _on_hint_button_pressed() -> void:
	if completed == true or current_word == target_word or current_word == solution_long[-2] or hints <= 0:
		return
	
	hints -= 1
	
	var hint = ""
	
	if undo_history.is_empty():
		hint = "Next word is [b]" + solution_long[1] + "[/b]."
		$Control/VBoxContainer/Hint.add_theme_font_size_override("normal_font_size", 28)
		$Control/VBoxContainer/Hint.add_theme_font_size_override("normal_font_size", 32)
	elif current_word in solution_long:
		var idx = solution_long.find(current_word)
		var next_word = solution_long[idx+1]
		
		var letter_idx = -1
		for i in range(len(next_word)):
			if current_word[i] == next_word[i]:
				pass
			else:
				letter_idx = i
				break
		
		var numbers_in_words = ["first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth"]
		
		$Control/VBoxContainer/Hint.add_theme_font_size_override("normal_font_size", 22)
		$Control/VBoxContainer/Hint.add_theme_font_size_override("normal_font_size", 26)
		hint = "Try changing the [b]" + numbers_in_words[letter_idx] + "[/b] letter."
		# TODO: ADD FLASHING IDICATOR ON THE CURRENT WORD LABEL
	else: 
		var undo_idx = -1
		for i in range(len(undo_history)):
			if solution_long[i] == undo_history[i]:
				undo_idx = i
			else:
				break
		
		$Control/VBoxContainer/Hint.add_theme_font_size_override("normal_font_size", 18)
		$Control/VBoxContainer/Hint.add_theme_font_size_override("normal_font_size", 22)
		hint = "You need to [b]undo[/b] back to [b]" + undo_history[undo_idx] + "[/b]."
	
	
	if hint:
		$Control/VBoxContainer/Hint.text = hint
