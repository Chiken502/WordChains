extends Node2D

var letter_being_draged: RigidBody2D
var prev_mouse_pos: Vector2 = Vector2.ZERO
var mouse_velocity: Vector2 = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var letter = raycast_check() # Check if a letter is under the mouse
			if letter: # if so, start draging
				letter_being_draged = letter.get_parent()
				letter_being_draged.being_draged = true
				letter_being_draged.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
		else: # button is released
			if letter_being_draged:
				letter_being_draged.freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
				if abs(mouse_velocity) > Vector2(0.2, 0.2): # Save mouse velocitry in the letter
					letter_being_draged.linear_velocity = mouse_velocity
				else:
					letter_being_draged.linear_velocity = Vector2.ZERO # set letter velocity to 0
				letter_being_draged.being_draged = false
			letter_being_draged = null


func raycast_check():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_bodies = true
	parameters.collide_with_areas = true
	parameters.collision_mask = 2
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if letter_being_draged: # Move letter to mouse
		var mouse_pos = get_global_mouse_position()
		mouse_velocity = (mouse_pos - prev_mouse_pos) / delta

		if letter_being_draged.global_position.distance_to(mouse_pos) > 1:
			letter_being_draged.global_position = mouse_pos
			if letter_being_draged.has_method("apply_stretch"):
				letter_being_draged.apply_stretch(mouse_velocity * delta)
		letter_being_draged.rotation_degrees = lerp(letter_being_draged.rotation_degrees, 0.0, 0.2)

		prev_mouse_pos = mouse_pos
