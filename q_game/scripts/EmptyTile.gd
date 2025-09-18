# extends TextureButton  # or Button, but TextureButton is better for images

# func _ready():
# 	# Set the texture for normal state
# 	texture_normal = preload("res://assets/empty_tile.png")
	
# 	# Set size to 30x30 pixels
# 	rect_min_size = Vector2(24, 24)
# 	rect_size = Vector2(24, 24)

extends TextureButton

var normal_texture = preload("res://assets/empty_tile.png")
var hover_texture = preload("res://assets/empty_tile_hover.png")  # Create this texture for the hover effect
var selected_texture = preload("res://assets/empty_tile_selected.png")  # Create this texture for the selected effect

var is_selected = false

func _ready():
	# Set the texture for normal state
	texture_normal = normal_texture
	
	# Set size to 30x30 pixels
	rect_min_size = Vector2(24, 24)
	rect_size = Vector2(24, 24)
	
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
		texture_normal = normal_texture

func _on_pressed():
	# Toggle the selection state
	is_selected = !is_selected
	if is_selected:
		texture_normal = selected_texture
	else:
		texture_normal = normal_texture
