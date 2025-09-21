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

var player_scores = {
	1: 0,
	2: 0
}
var tiles_placed_this_turn = []

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
	_place_initial_random_tile()

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
		if not _can_place_tile(tile, selected_tile_texture):
			print("Invalid placement.")
			return

		var success = tile.set_tile_texture(selected_tile_texture)

		if success:
			# Track placed tile + its texture
			tiles_placed_this_turn.append({
				"tile": tile,
				"texture": selected_tile_texture
			})

			_remove_used_tile(selected_tile_texture, selected_player_id)
			selected_tile_texture = null
			selected_player_id = null

func _on_end_turn_pressed():
	if tiles_placed_this_turn.size() == 0:
		print("No tiles placed this turn.")
		return

	var turn_score = 0
	for placement in tiles_placed_this_turn:
		var tile = placement["tile"]
		var texture = placement["texture"]
		var index = $ScrollContainer/GridContainer.get_children().find(tile)
		turn_score += _calculate_score(index, texture)

	# Hand Bonus (player used all tiles this turn)
	if _player_played_all_tiles(current_player):
		turn_score += 6
		print("HAND BONUS! +6 Points")

	player_scores[current_player] += turn_score

	print("Player %d scored %d this turn. Total: %d" % [
		current_player, turn_score, player_scores[current_player]
	])

	# Update UI if needed
	$TopScoreLabel.text = "Player 1: %d" % player_scores[1]
	$BottomScoreLabel.text = "Player 2: %d" % player_scores[2]

	# Clean up for next turn
	tiles_placed_this_turn.clear()
	selected_tile_texture = null
	selected_player_id = null

	_refill_player_tiles(current_player)
	current_player = 2 if current_player == 1 else 1

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

func _can_place_tile(tile_node, selected_texture):
	var grid = $ScrollContainer/GridContainer
	var index = grid.get_children().find(tile_node)

	if index == -1:
		return false  # Tile not found in grid

	var columns = 25  # Must match the column count you used
	var neighbors = []

	var up    = index - columns
	var down  = index + columns
	var left = -1
	var right = -1

	if index % columns != 0:
		left = index - 1

	if index % columns != columns - 1:
		right = index + 1


	if up >= 0: neighbors.append(grid.get_child(up))
	if down < grid.get_child_count(): neighbors.append(grid.get_child(down))
	if left != -1: neighbors.append(grid.get_child(left))
	if right != -1: neighbors.append(grid.get_child(right))

	var selected_name = selected_texture.resource_path.get_file().get_basename()
	var selected_color = selected_name.split("_")[0]
	var selected_shape = selected_name.split("_")[1]

	var has_non_empty_neighbor = false

	for neighbor in neighbors:
		if not neighbor is EmptyTile:
			continue  # Not the right type

		if neighbor.is_set:
			has_non_empty_neighbor = true
			var neighbor_texture = neighbor.base_texture
			var neighbor_name = neighbor_texture.resource_path.get_file().get_basename()
			var neighbor_color = neighbor_name.split("_")[0]
			var neighbor_shape = neighbor_name.split("_")[1]

			# Must match either color or shape
			var matches_color = (selected_color == neighbor_color)
			var matches_shape = (selected_shape == neighbor_shape)

			if not (matches_color or matches_shape):
				return false  # One of the neighbors doesn't match

	# Must have at least one adjacent non-empty tile
	return has_non_empty_neighbor

func _load_tile_textures():
	for color in COLORS:
		for shape in SHAPES:
			var path = "res://assets/%s_%s.png" % [color, shape]
			var texture = load(path)
			if texture:
				TILE_TEXTURES.append(texture)
				TILE_TEXTURES_DICT[texture] = 15  # Set initial count

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

func _place_initial_random_tile():
	var grid = $ScrollContainer/GridContainer
	var children = grid.get_children()

	if children.size() == 0:
		return

	# Get random tile
	var random_tile_index = randi() % children.size()
	var random_tile = children[random_tile_index]

	# Get random texture
	var random_texture = _get_random_available_texture()

	if random_texture and random_tile:
		var success = random_tile.set_tile_texture(random_texture)
		if success and TILE_TEXTURES_DICT.has(random_texture):
			TILE_TEXTURES_DICT[random_texture] -= 1

func _calculate_score(index, texture):
	var grid = $ScrollContainer/GridContainer
	var columns = 25
	var total_score = 1  # +1 base point for placing a tile

	var texture_name = texture.resource_path.get_file().get_basename()
	var selected_color = texture_name.split("_")[0]
	var selected_shape = texture_name.split("_")[1]

	var row_score = _count_line(index, columns, 1, selected_color, selected_shape)  # horizontal
	var col_score = _count_line(index, columns, columns, selected_color, selected_shape)  # vertical

	total_score += row_score
	total_score += col_score

	# Check for Q bonus in row or column
	if row_score + 1 == 6 and _is_q_line(index, columns, 1):
		total_score += 10
		print("Q BONUS! +10 Points (Row)")

	if col_score + 1 == 6 and _is_q_line(index, columns, columns):
		total_score += 10
		print("Q BONUS! +10 Points (Column)")

	return total_score

func _count_line(index, columns, step, color, shape):
	var grid = $ScrollContainer/GridContainer
	var count = 0

	# Check in both directions
	for direction in [-1, 1]:
		var i = index + step * direction
		while i >= 0 and i < grid.get_child_count():
			var tile = grid.get_child(i)
			if tile is EmptyTile and tile.is_set:
				var tname = tile.base_texture.resource_path.get_file().get_basename()
				var tcolor = tname.split("_")[0]
				var tshape = tname.split("_")[1]

				# If it matches either color or shape, continue
				if tcolor == color or tshape == shape:
					count += 1
					i += step * direction
				else:
					break
			else:
				break

	return count

func _is_q_line(index, columns, step):
	var grid = $ScrollContainer/GridContainer
	var textures = []

	textures.append(grid.get_child(index).base_texture)

	for direction in [-1, 1]:
		var i = index + step * direction
		while i >= 0 and i < grid.get_child_count():
			var tile = grid.get_child(i)
			if tile is EmptyTile and tile.is_set:
				textures.append(tile.base_texture)
				i += step * direction
			else:
				break

	if textures.size() != 6:
		return false

	var colors = []
	var shapes = []

	for tex in textures:
		var name = tex.resource_path.get_file().get_basename()
		var color = name.split("_")[0]
		var shape = name.split("_")[1]

		if not color in colors:
			colors.append(color)
		if not shape in shapes:
			shapes.append(shape)

	# Q = all same color + 6 unique shapes OR all same shape + 6 unique colors
	var is_q = (colors.size() == 1 and shapes.size() == 6) or (shapes.size() == 1 and colors.size() == 6)
	return is_q

func _player_played_all_tiles(player_id):
	var container = $TopContainer if player_id == 1 else $BottomContainer

	for child in container.get_children():
		if child is UserTile:
			return false  # Still has at least one tile

	return true
