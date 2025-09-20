#extends Control
#
#const EMPTY_BUTTON_SCENE = preload("res://scenes/EmptyTile.tscn")
#const USER_BUTTON_SCENE = preload("res://scenes/UserTile.tscn")
#
#var COLORS = ["red", "green", "blue", "yellow", "purple", "orange"]
#var SHAPES = ["star", "circle", "diamond", "square", "8star", "clover"]
#var TILE_TEXTURES = []  # Will hold all 36 textures
#var selected_tile_texture = null  # This holds the texture to place on the board
#
#func _ready():
#	var grid = $ScrollContainer/GridContainer
#	var scroll = $ScrollContainer
#	var top_container = $TopContainer
#	var bottom_container = $BottomContainer
#
#	var available_height = 600
#	var available_width = 1000
#
#	# === GRID SETUP ===
#	var rows = 25
#	var columns = 25
#	var total_height = rows * 60
#	var total_width = columns * 60
#
#	grid.rect_min_size = Vector2(total_width, total_height)
#	scroll.rect_min_size = Vector2(1600, 500)
#
#	for i in range(rows * columns):
#		var btn = EMPTY_BUTTON_SCENE.instance()
#		btn.connect("tile_clicked", self, "_on_empty_tile_clicked")
#		grid.add_child(btn)
#
#
#	# === LOAD TILE TEXTURES ===
#	_load_tile_textures()
#
#	# === TOP & BOTTOM TILE SETUP ===
#	var all_random_textures = TILE_TEXTURES.duplicate()
#	all_random_textures.shuffle()
#
#	for i in range(6):
#
#		var top_btn = USER_BUTTON_SCENE.instance()
#		var bottom_btn = USER_BUTTON_SCENE.instance()
#
#		# Assign random textures
#		var top_texture = all_random_textures.pop_front()
#		var bottom_texture = all_random_textures.pop_front()
#
#		top_btn.texture_normal = top_texture
#		bottom_btn.texture_normal = bottom_texture
#
#		# Disable interactivity if needed
#		top_btn.connect("user_tile_selected", self, "_on_user_tile_selected")
#		bottom_btn.connect("user_tile_selected", self, "_on_user_tile_selected")
#
#
#		top_container.add_child(top_btn)
#		bottom_container.add_child(bottom_btn)
#
#func _on_user_tile_selected(texture):
#	selected_tile_texture = texture
#
#func _on_empty_tile_clicked(tile):
#	if selected_tile_texture:
#		tile.set_tile_texture(selected_tile_texture)
#		selected_tile_texture = null  # Clear selection after placing
#
#
#func _load_tile_textures():
#	for color in COLORS:
#		for shape in SHAPES:
#			var path = "res://assets/%s_%s.png" % [color, shape]
#			var texture = load(path)
#			if texture:
#				TILE_TEXTURES.append(texture)
#
#
#
#extends Control
#
#const EMPTY_BUTTON_SCENE = preload("res://scenes/EmptyTile.tscn")
#const USER_BUTTON_SCENE = preload("res://scenes/UserTile.tscn")
#
#var COLORS = ["red", "green", "blue", "yellow", "purple", "orange"]
#var SHAPES = ["star", "circle", "diamond", "square", "8star", "clover"]
#var TILE_TEXTURES = []  # Will hold all 36 textures
#
#var selected_tile_texture = null
#var selected_player_id = null
#var current_player = 1  # 1 = top user, 2 = bottom user
#
#func _ready():
#	var grid = $ScrollContainer/GridContainer
#	var scroll = $ScrollContainer
#	var top_container = $TopContainer
#	var bottom_container = $BottomContainer
#
#	var available_height = 600
#	var available_width = 1000
#
#	# === GRID SETUP ===
#	var rows = 25
#	var columns = 25
#	var total_height = rows * 60
#	var total_width = columns * 60
#
#	grid.rect_min_size = Vector2(total_width, total_height)
#	scroll.rect_min_size = Vector2(1600, 500)
#
#	for i in range(rows * columns):
#		var btn = EMPTY_BUTTON_SCENE.instance()
#		btn.connect("tile_clicked", self, "_on_empty_tile_clicked")
#		grid.add_child(btn)
#
#	# === LOAD TILE TEXTURES ===
#	_load_tile_textures()
#
#	# === TOP & BOTTOM TILE SETUP ===
#	var all_random_textures = TILE_TEXTURES.duplicate()
#	all_random_textures.shuffle()
#
#	for i in range(6):
#		var top_btn = USER_BUTTON_SCENE.instance()
#		top_btn.player_id = 1
#
#		var bottom_btn = USER_BUTTON_SCENE.instance()
#		bottom_btn.player_id = 2
#
#		var top_texture = all_random_textures.pop_front()
#		var bottom_texture = all_random_textures.pop_front()
#
#		top_btn.texture_normal = top_texture
#		bottom_btn.texture_normal = bottom_texture
#
#		top_btn.connect("user_tile_selected", self, "_on_user_tile_selected")
#		bottom_btn.connect("user_tile_selected", self, "_on_user_tile_selected")
#
#		top_container.add_child(top_btn)
#		bottom_container.add_child(bottom_btn)
#
#	_update_tile_turns()
#
#func _on_user_tile_selected(texture, player_id):
#	if player_id == current_player:
#		selected_tile_texture = texture
#		selected_player_id = player_id
#
#func _on_empty_tile_clicked(tile):
#	if selected_tile_texture and selected_player_id == current_player:
#		tile.set_tile_texture(selected_tile_texture)
#		selected_tile_texture = null
#		selected_player_id = null
#
#		# Switch turns
#		current_player = 2 if current_player == 1 else 1
#		_update_tile_turns()
#		print("Now it's Player %d's turn" % current_player)
#
#func _load_tile_textures():
#	for color in COLORS:
#		for shape in SHAPES:
#			var path = "res://assets/%s_%s.png" % [color, shape]
#			var texture = load(path)
#			if texture:
#				TILE_TEXTURES.append(texture)
#
#func _update_tile_turns():
#	var top_container = $TopContainer
#	var bottom_container = $BottomContainer
#
#	for tile in top_container.get_children():
#		tile.is_my_turn = (current_player == 1)
#
#	for tile in bottom_container.get_children():
#		tile.is_my_turn = (current_player == 2)


extends Control

const EMPTY_BUTTON_SCENE = preload("res://scenes/EmptyTile.tscn")
const USER_BUTTON_SCENE = preload("res://scenes/UserTile.tscn")

var COLORS = ["red", "green", "blue", "yellow", "purple", "orange"]
var SHAPES = ["star", "circle", "diamond", "square", "8star", "clover"]
var TILE_TEXTURES = []
var TILE_TEXTURES_DICT = {}

var selected_tile_texture = null
var selected_player_id = null
var current_player = 1  # 1 = Top player, 2 = Bottom player

func _ready():
	randomize()
	
	var grid = $ScrollContainer/GridContainer
	var scroll = $ScrollContainer
	var top_container = $TopContainer
	var bottom_container = $BottomContainer

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

	_load_tile_textures()

	var all_random_textures = TILE_TEXTURES.duplicate()
	all_random_textures.shuffle()

	for i in range(6):
		var top_btn = USER_BUTTON_SCENE.instance()
		top_btn.player_id = 1

		var bottom_btn = USER_BUTTON_SCENE.instance()
		bottom_btn.player_id = 2

		var top_texture = all_random_textures.pop_front()
		var bottom_texture = all_random_textures.pop_front()

		top_btn.texture_normal = top_texture
		bottom_btn.texture_normal = bottom_texture
		# Decrease count for initial tiles assigned
		if TILE_TEXTURES_DICT.has(top_texture):
			TILE_TEXTURES_DICT[top_texture] -= 1
		if TILE_TEXTURES_DICT.has(bottom_texture):
			TILE_TEXTURES_DICT[bottom_texture] -= 1
			
		top_btn.connect("user_tile_selected", self, "_on_user_tile_selected")
		bottom_btn.connect("user_tile_selected", self, "_on_user_tile_selected")

		top_container.add_child(top_btn)
		bottom_container.add_child(bottom_btn)

	_update_tile_turns()

	# ✅ Connect end turn button
	$EndTurnButton.connect("pressed", self, "_on_end_turn_pressed")

func _on_user_tile_selected(texture, player_id):
	if player_id == current_player:
		selected_tile_texture = texture
		selected_player_id = player_id

func _on_empty_tile_clicked(tile):
	if selected_tile_texture and selected_player_id == current_player:
		var success = tile.set_tile_texture(selected_tile_texture)

		if success:
			_remove_used_tile(selected_tile_texture, selected_player_id)
			selected_tile_texture = null
			selected_player_id = null

func _on_end_turn_pressed():
	selected_tile_texture = null
	selected_player_id = null
	
	_refill_player_tiles(current_player)
	current_player = 2 if current_player == 1 else 1
	print("Now it's Player %d's turn" % current_player)
	
	_update_tile_turns()
	
func _remove_used_tile(texture, player_id):
	var container = $TopContainer if player_id == 1 else $BottomContainer

	for child in container.get_children():
		if child.has_method("get_texture") and child.get_texture() == texture:
			var empty_tile = EMPTY_BUTTON_SCENE.instance()

			# Get index manually
			var index = -1
			for i in range(container.get_child_count()):
				if container.get_child(i) == child:
					index = i
					break

			container.remove_child(child)
			child.queue_free()
			container.add_child(empty_tile)

			# Move to correct position
			if index != -1:
				container.move_child(empty_tile, index)

			# DO NOT decrease TILE_TEXTURES_DICT here anymore
			break



func _load_tile_textures():
	for color in COLORS:
		for shape in SHAPES:
			var path = "res://assets/%s_%s.png" % [color, shape]
			var texture = load(path)
			if texture:
				TILE_TEXTURES.append(texture)
				TILE_TEXTURES_DICT[texture] = 1  # Set initial count

func _update_tile_turns():
	var end_turn_button = $EndTurnButton
	var top_container = $TopContainer
	var bottom_container = $BottomContainer

	for tile in top_container.get_children():
		if "is_my_turn" in tile:
			tile.is_my_turn = (current_player == 1)

	for tile in bottom_container.get_children():
		if "is_my_turn" in tile:
			tile.is_my_turn = (current_player == 2)
			
	if current_player == 1:
		end_turn_button.rect_position = Vector2(178, 44)
	else:
		end_turn_button.rect_position = Vector2(178, 707)

func _refill_player_tiles(player_id):
	var container = $TopContainer if player_id == 1 else $BottomContainer

	for i in range(container.get_child_count()):
		var child = container.get_child(i)

		# If it's not a UserTile (i.e., it's an EmptyTile), refill it
		if child is EmptyTile:
			var new_tile = USER_BUTTON_SCENE.instance()
			new_tile.player_id = player_id
			new_tile.connect("user_tile_selected", self, "_on_user_tile_selected")

			var texture = _get_random_available_texture()
			if texture:
				new_tile.texture_normal = texture
				TILE_TEXTURES_DICT[texture] -= 1

				container.remove_child(child)
				child.queue_free()

				container.add_child(new_tile)
				container.move_child(new_tile, i)

func _get_random_available_texture():
	var available = []

	for texture in TILE_TEXTURES_DICT.keys():
		if TILE_TEXTURES_DICT[texture] > 0:
			available.append(texture)

	if available.size() == 0:
		return null

	return available[randi() % available.size()]
