extends Label

# NOTE: CONSIDER NOTE HAVING THE FLASH ANIMATION. Use screen shake and sound instead or smth


signal letter_changed(node, letter)

var scripted_parent : Node2D# See if this is useful or needed

var letter = "A"
var colliding_body : RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_settings.font_color = ColorManager.colors[ColorManager.currentColor][1]
	label_settings.outline_color = ColorManager.colors[ColorManager.currentColor][1]
	
	$MainParticles.modulate = ColorManager.colors[ColorManager.currentColor][1]
	
	_on_resized()

func change_letter(new_letter : String):
	letter_changed.emit(self, new_letter) # game will check if letter makes a legal word
	#var node = await scripted_parent.word_confirmed
	#if node == self:
		#print("sucseces")
		#text = new_letter.to_upper()
		#letter = new_letter.to_upper()

# Calculates particle position so its always in the center
func _on_resized() -> void:
	$MainParticles.position = size/2

# handles a falling letter being put into this slot
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("falling letter"):
		if body.being_draged:
			var new_letter = body.letter
			colliding_body = body
			letter_changed.emit(self, new_letter)

# New letter is legal, so we can keep it
func _on_word_confirmed(node, new_letter : String):
	if node == self:
		if colliding_body: # Delete falling letter node
			text = new_letter.to_upper()
			letter = new_letter.to_upper()
			
			colliding_body.queue_free()
			colliding_body = null
			
			$MainParticles.emitting = true

# Word was not legal
func _on_word_not_found(_node):
	MusicManager.error_sound()

# Called when puzzle is completed
func succses():
	$MainParticles/FinishedParticles.emitting = true

# Called when undo is used
func flash_undo():
	$MainParticles/UndoParticles.emitting = true
