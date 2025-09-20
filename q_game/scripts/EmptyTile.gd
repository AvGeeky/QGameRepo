extends TextureButton

class_name EmptyTile

var normal_texture = preload("res://assets/empty_tile.png")
var hover_texture = preload("res://assets/empty_tile_hover.png")
var selected_texture = preload("res://assets/blue_star.png")

var base_texture = normal_texture
var is_selected = false
var is_set = false  # ✅ Add this flag

signal tile_clicked(tile_node)

func _ready():
	if not texture_normal:
		texture_normal = normal_texture
	base_texture = normal_texture

	rect_min_size = Vector2(60, 60)
	rect_size = Vector2(60, 60)

	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("pressed", self, "_on_pressed")

func _on_mouse_entered():
	if not is_selected and not is_set:
		texture_normal = hover_texture

func _on_mouse_exited():
	if not is_selected and not is_set:
		texture_normal = base_texture

func _on_pressed():
	emit_signal("tile_clicked", self)

func set_tile_texture(texture):
	if is_set:
		return false  # already set, can't override

	texture_normal = texture
	base_texture = texture
	is_selected = false
	is_set = true  # mark as set
	return true
