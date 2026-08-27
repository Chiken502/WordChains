extends RigidBody2D

var letters = [
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
]
var letter = ""
var being_draged = false

const COLLISION_THRESHOLD = 20.0
const MAX_COLLISOIN_IMPULSE = 100.0
const SOUND_COOLDOWN = 0.1
var last_sound_time: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = ColorManager.colors[ColorManager.currentColor][1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if position.y > 712: # keep above groud plane
		position.y = 712
	elif position.y < -800 and linear_velocity.y < 0: # Prevents form flying off screen
		linear_velocity.y = 0


func get_ready():
	$Label.text = letter

	self.center_of_mass_mode = CENTER_OF_MASS_MODE_CUSTOM
	$Sprite2D.position = $Label.position
	#var texture = await capture_label_image($Label)
	var texture_path = "res://Letter Images/" + letter + ".res"
	$Sprite2D.texture = load(texture_path)

	make_collision2D()
	$Sprite2D.position = Vector2.ZERO


# Not used in game. This is a tool function that was used to make "res://Letter Images/..."
func _capture_label_image(label: Label) -> Texture:
	var vp = get_viewport()
	vp.disable_3d = true
	vp.transparent_bg = true
	#vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var orginal_vp_size = vp.get_visible_rect().size
	vp.size = Vector2i(label.get_rect().size)

	# Duplicate the label so the original isn’t disturbed.
	var label_copy = label.duplicate()
	label_copy.position = Vector2.ZERO # reset position in the viewport
	vp.add_child(label_copy)
	#vp.force_update()
	await get_tree().process_frame
	var texture = vp.get_texture().get_image()

	label_copy.queue_free()
	vp.size = orginal_vp_size
	vp.transparent_bg = false
	$Sprite2D.hide()

	return ImageTexture.create_from_image(texture)


# Make a collision shape from the image
func make_collision2D():
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha($Sprite2D.texture.get_image())

	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, $Sprite2D.texture.get_size()), 1)
	for poly in polys:
		var collision_polygon = CollisionPolygon2D.new()
		collision_polygon.polygon = poly
		add_child(collision_polygon)

		#if $Sprite2D.centered:
		#collision_polygon.position = collision_polygon.position - Vector2(bitmap.get_size()/2)
		#collision_polygon.position.x = collision_polygon.position.x - bitmap.get_size().x/2
		#collision_polygon.position.y = collision_polygon.position.y - bitmap.get_size().y/2
		collision_polygon.position = $Label.position #- Vector2(8, 0)

		#if $Sprite2D.position != Vector2.ZERO:
		#collision_polygon.position = $Sprite2D.position
		##$Sprite2D.position = collision_polygon.position
	$Sprite2D.hide()


# handles collision sounds
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_sound_time < SOUND_COOLDOWN:
		return #prevent triggering too often

	for i in range(state.get_contact_count()):
		var impulse = state.get_contact_impulse(i).length()
		if impulse > COLLISION_THRESHOLD:
			last_sound_time = current_time
			var volume_factor = clamp(
				(impulse - COLLISION_THRESHOLD) / (MAX_COLLISOIN_IMPULSE - COLLISION_THRESHOLD),
				0.0,
				1.0,
			)
			play_collision_sound(volume_factor)
			break


func play_collision_sound(volume_factor: float):
	var sound_player = AudioStreamPlayer.new()
	sound_player.stream = preload("res://Audio/Sfx/collision.tres")

	sound_player.volume_db = linear_to_db(volume_factor)
	sound_player.bus = "SFX Bus"

	add_child(sound_player)
	sound_player.play()

	sound_player.connect("finished", sound_player.queue_free)


# More sound stuff. Commented out as sounds arn't in yet
func _on_body_entered(_body: Node) -> void:
	pass
	#if being_draged:
	#return
	#
	#var forces
	#if body is RigidBody2D:
	#forces = self.linear_velocity.length() + body.linear_velocity.length()
	#else:
	#forces = self.linear_velocity.length()
	#
	## Remap the forces variable to the appropriate volume range (this is a handy function I found online)
	#var audio_volume = -50 + (pow(forces, 1.5) * 5)
	## Set the AudioStreamPlayer's volume accordingly
	#if $AudioStreamPlayer2D.playing:
	#return
	#$AudioStreamPlayer2D.volume_db = clamp(audio_volume, -50, 5)
	#$AudioStreamPlayer2D.play()
