extends Control

const EMPTY_BUTTON_SCENE = preload("res://scenes/EmptyTile.tscn")
const USER_BUTTON_SCENE = preload("res://scenes/UserTile.tscn")

var COLORS = ["red", "green", "blue", "yellow", "purple", "orange"]
var SHAPES = ["star", "circle", "diamond", "square", "8star", "clover"]
var TILE_TEXTURES = []  # Will hold all 36 textures
var selected_tile_texture = null  # This holds the texture to place on the board

func _ready():
	var grid = $ScrollContainer/GridContainer
	var scroll = $ScrollContainer
	var top_container = $TopContainer
	var bottom_container = $BottomContainer

	var available_height = 600
	var available_width = 1000

	# === GRID SETUP ===
	var rows = 25
	var columns = 25
	var total_height = rows * 60
	var total_width = columns * 60

	grid.rect_min_size = Vector2(total_width, total_height)
	scroll.rect_min_size = Vector2(1600, 500)

	for i in range(rows * columns):
		var btn = EMPTY_BUTTON_SCENE.instance()
		btn.connect("tile_clicked", self, "_on_empty_tile_clicked")
		grid.add_child(btn)


	# === LOAD TILE TEXTURES ===
	_load_tile_textures()

	# === TOP & BOTTOM TILE SETUP ===
	var all_random_textures = TILE_TEXTURES.duplicate()
	all_random_textures.shuffle()
	
	for i in range(6):
		
		var top_btn = USER_BUTTON_SCENE.instance()
		var bottom_btn = USER_BUTTON_SCENE.instance()

		# Assign random textures
		var top_texture = all_random_textures.pop_front()
		var bottom_texture = all_random_textures.pop_front()

		top_btn.texture_normal = top_texture
		bottom_btn.texture_normal = bottom_texture

		# Disable interactivity if needed
		top_btn.connect("user_tile_selected", self, "_on_user_tile_selected")
		bottom_btn.connect("user_tile_selected", self, "_on_user_tile_selected")


		top_container.add_child(top_btn)
		bottom_container.add_child(bottom_btn)

func _on_user_tile_selected(texture):
	selected_tile_texture = texture

func _on_empty_tile_clicked(tile):
	if selected_tile_texture:
		tile.set_tile_texture(selected_tile_texture)
		selected_tile_texture = null  # Clear selection after placing


func _load_tile_textures():
	for color in COLORS:
		for shape in SHAPES:
			var path = "res://assets/%s_%s.png" % [color, shape]
			var texture = load(path)
			if texture:
				TILE_TEXTURES.append(texture)
