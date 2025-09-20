extends TextureButton

class_name EmptyTile

var normal_texture = preload("res://assets/empty_tile.png")
var hover_texture = preload("res://assets/empty_tile_hover.png")  # Create this texture for the hover effect
var selected_texture = preload("res://assets/blue_star.png")  # Create this texture for the selected effect
var base_texture = normal_texture
var is_selected = false

func _ready():
	# Set the texture for normal state
	if not texture_normal:
		texture_normal = normal_texture
	base_texture = texture_normal
	# Set size to 35x35 pixels
	rect_min_size = Vector2(60, 60)
	rect_size = Vector2(60, 60)

	# Connect signals
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("pressed", self, "_on_pressed")

func _on_mouse_entered():
	# Change texture when mouse hovers over
	if not is_selected:
		texture_normal = hover_texture

func _on_mouse_exited():
	# Revert to normal texture if not selected
	if not is_selected:
		texture_normal = base_texture

signal tile_clicked(tile_node)

func _on_pressed():
	emit_signal("tile_clicked", self)

#	else:
#		texture_normal = normal_texture

func set_tile_texture(texture):
	if base_texture != normal_texture:
		# Already set to a non-empty tile, ignore
		return

	texture_normal = texture
	base_texture = texture
	is_selected = false
	return true
