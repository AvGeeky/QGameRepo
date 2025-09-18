extends TextureRect

var default_tint: Color = Color(1, 1, 1, 1)
var hover_tint: Color = Color(0.6, 0.8, 1.0, 1)

func _ready():
	custom_minimum_size = Vector2(100, 100)
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_filter = TextureFilter.TEXTURE_FILTER_NEAREST
	modulate = default_tint
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	modulate = hover_tint

func _on_mouse_exited():
	modulate = default_tint
