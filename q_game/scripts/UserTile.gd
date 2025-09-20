#extends TextureButton
#
#var normal_texture = preload("res://assets/empty_tile.png")
#var selected_texture = preload("res://assets/blue_star.png")  # Create this texture for the selected effect
#var base_texture = normal_texture
#var is_selected = false
#const HOVER_OPACITY = 0.6
#
#func _ready():
#	# Set the texture for normal state
#	if not texture_normal:
#		texture_normal = normal_texture
#	base_texture = texture_normal
#	# Set size to 35x35 pixels
#	rect_min_size = Vector2(60, 60)
#	rect_size = Vector2(60, 60)
#
#	# Connect signals
#	connect("mouse_entered", self, "_on_mouse_entered")
#	connect("mouse_exited", self, "_on_mouse_exited")
#	connect("pressed", self, "_on_pressed")
#
#func _on_mouse_entered():
#	# Change texture when mouse hovers over
#	if not is_selected:
#		modulate.a = HOVER_OPACITY
#
#func _on_mouse_exited():
#	# Revert to normal texture if not selected
#	if not is_selected:
#		modulate.a = 1.0
#
#signal user_tile_selected(texture)
#
#func _on_pressed():
#	is_selected = !is_selected
#	texture_normal = base_texture
#	modulate.a = 1.0
#	if is_selected:
#		emit_signal("user_tile_selected", base_texture)
#	else:
#		emit_signal("user_tile_selected", null)

#
#extends TextureButton
#
#var normal_texture = preload("res://assets/empty_tile.png")
#var selected_texture = preload("res://assets/blue_star.png")  # optional, not used directly here
#var base_texture = normal_texture
#var is_selected = false
#const HOVER_OPACITY = 0.6
#
#var player_id = 0  # Assigned by GameBoard
#var is_my_turn = false  # Controlled by GameBoard
#
#signal user_tile_selected(texture, player_id)
#
#func _ready():
#	if not texture_normal:
#		texture_normal = normal_texture
#	base_texture = texture_normal
#	rect_min_size = Vector2(60, 60)
#	rect_size = Vector2(60, 60)
#
#	connect("mouse_entered", self, "_on_mouse_entered")
#	connect("mouse_exited", self, "_on_mouse_exited")
#	connect("pressed", self, "_on_pressed")
#
#func _on_mouse_entered():
#	if is_my_turn and not is_selected:
#		modulate.a = HOVER_OPACITY
#
#func _on_mouse_exited():
#	if not is_selected:
#		modulate.a = 1.0
#
#func _on_pressed():
#	if not is_my_turn:
#		return
#	is_selected = !is_selected
#	texture_normal = base_texture
#	modulate.a = 1.0
#	if is_selected:
#		emit_signal("user_tile_selected", base_texture, player_id)
#	else:
#		emit_signal("user_tile_selected", null, player_id)


extends TextureButton

var normal_texture = preload("res://assets/empty_tile.png")
var base_texture = normal_texture
var is_selected = false
const HOVER_OPACITY = 0.6

var player_id = 0
var is_my_turn = false

signal user_tile_selected(texture, player_id)

func _ready():
	if not texture_normal:
		texture_normal = normal_texture
	base_texture = texture_normal
	rect_min_size = Vector2(60, 60)
	rect_size = Vector2(60, 60)

	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("pressed", self, "_on_pressed")

func _on_mouse_entered():
	if is_my_turn and not is_selected:
		modulate.a = HOVER_OPACITY

func _on_mouse_exited():
	if not is_selected:
		modulate.a = 1.0

func _on_pressed():
	if not is_my_turn:
		return
	is_selected = !is_selected
	texture_normal = base_texture
	modulate.a = 1.0
	if is_selected:
		emit_signal("user_tile_selected", base_texture, player_id)
	else:
		emit_signal("user_tile_selected", null, player_id)

func get_texture():
	return base_texture
