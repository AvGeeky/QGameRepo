extends Control
const SCORE_LIMIT = 100  # ⬅️ Adjust this to whatever threshold you want

# --- Constants & Scenes ---
const EMPTY_BUTTON_SCENE = preload("res://scenes/EmptyTile.tscn")
const USER_BUTTON_SCENE = preload("res://scenes/UserTile.tscn")

const COLORS = ["red", "green", "blue", "yellow", "purple", "orange"]
const SHAPES = ["star", "circle", "diamond", "square", "8star", "clover"]
const AI_PLAYER_ID = 2

# --- Game State Variables ---
var TILE_TEXTURES = []
var TILE_TEXTURES_DICT = {}

var selected_tile_texture = null
var selected_player_id = null
var current_player = 1  # 1 = Top player, 2 = Bottom player

var player_scores = { 1: 0, 2: 0 }
var tiles_placed_this_turn = []

# --- Node References ---
onready var top_hud = $MainLayout/VBoxContainer/TopPlayerHUD
onready var bottom_hud = $MainLayout/VBoxContainer/BottomPlayerHUD
onready var grid = $MainLayout/VBoxContainer/ScrollContainer/GridContainer
onready var end_turn_button = $MainLayout/VBoxContainer/EndTurnButton

# --- Godot Functions ---

func _ready():
	randomize()
	
	var top_container = top_hud.get_hand_container()
	var bottom_container = bottom_hud.get_hand_container()

	var rows = 25
	var columns = 25
	grid.rect_min_size = Vector2(columns * 60, rows * 60)
	grid.columns = columns

	for i in range(rows * columns):
		var btn = EMPTY_BUTTON_SCENE.instance()
		btn.connect("tile_clicked", self, "_on_empty_tile_clicked")
		grid.add_child(btn)

	_load_tile_textures()
	# --- AI INITIALIZATION ---
	# This must be called after _load_tile_textures()
	init_texture_mappings_from_array(TILE_TEXTURES)

	var all_random_textures = TILE_TEXTURES.duplicate()
	all_random_textures.shuffle()
	_place_initial_random_tile()

	top_hud.set_player_name("Player 1")
	bottom_hud.set_player_name("Player 2")

	for i in range(6):
		var top_btn = USER_BUTTON_SCENE.instance()
		top_btn.player_id = 1
		var top_texture = all_random_textures.pop_front()
		top_btn.texture_normal = top_texture
		if TILE_TEXTURES_DICT.has(top_texture): TILE_TEXTURES_DICT[top_texture] -= 1
		top_btn.connect("user_tile_selected", self, "_on_user_tile_selected")
		top_container.add_child(top_btn)
		
		var bottom_btn = USER_BUTTON_SCENE.instance()
		bottom_btn.player_id = 2
		var bottom_texture = all_random_textures.pop_front()
		bottom_btn.texture_normal = bottom_texture
		if TILE_TEXTURES_DICT.has(bottom_texture): TILE_TEXTURES_DICT[bottom_texture] -= 1
		bottom_btn.connect("user_tile_selected", self, "_on_user_tile_selected")
		bottom_container.add_child(bottom_btn)

	_update_tile_turns()
	end_turn_button.connect("pressed", self, "_on_end_turn_pressed")


# --- UI Signal Handlers ---

func _on_user_tile_selected(texture, player_id):
	if current_player == AI_PLAYER_ID: return
	if player_id == current_player:
		selected_tile_texture = texture
		selected_player_id = player_id

func _on_empty_tile_clicked(tile):
	if current_player == AI_PLAYER_ID: return
	if selected_tile_texture and selected_player_id == current_player:
		if not _can_place_tile(tile, selected_tile_texture):
			print("Invalid placement.")
			return
		var success = tile.set_tile_texture(selected_tile_texture)
		if success:
			tiles_placed_this_turn.append({ "tile": tile, "texture": selected_tile_texture })
			_remove_used_tile(selected_tile_texture, selected_player_id)
			selected_tile_texture = null
			selected_player_id = null

func _on_end_turn_pressed():
	if current_player == AI_PLAYER_ID: return
	if tiles_placed_this_turn.empty():
		print("Passing turn.")
		_end_turn_for_player(current_player, 0)
		return

	var turn_score = 0
	for placement in tiles_placed_this_turn:
		var index = grid.get_children().find(placement.tile)
		turn_score += _calculate_score(index, placement.texture)

	if _player_played_all_tiles(current_player):
		turn_score += 6
		print("HAND BONUS! +6 Points")
	
	_end_turn_for_player(current_player, turn_score)


# --- Core Game Loop & Logic ---

func _end_turn_for_player(player_id, score_this_turn):
	print("Player %d's turn ended. Scored: %d" % [player_id, score_this_turn])

	player_scores[player_id] += score_this_turn
	top_hud.update_score(player_scores[1])
	bottom_hud.update_score(player_scores[2])

	tiles_placed_this_turn.clear()
	selected_tile_texture = null
	selected_player_id = null

	_refill_player_tiles(player_id)
	if _check_for_end_of_game():
		_end_game()
		return

	current_player = 2 if player_id == 1 else 1
	_update_tile_turns()

func _update_tile_turns():
	top_hud.set_active_turn(current_player == 1)
	bottom_hud.set_active_turn(current_player == 2)

	var top_container = top_hud.get_hand_container()
	for tile in top_container.get_children():
		if "is_my_turn" in tile: tile.is_my_turn = (current_player == 1)
	var bottom_container = bottom_hud.get_hand_container()
	for tile in bottom_container.get_children():
		if "is_my_turn" in tile: tile.is_my_turn = (current_player == 2)
			
	if current_player == AI_PLAYER_ID:
		var timer = Timer.new()
		timer.wait_time = 0.5 # Short delay for UX
		timer.one_shot = true
		# --- CALL THE OPTIMIZED AI ---
		timer.connect("timeout", self, "start_ai_turn_optimized")
		add_child(timer)
		timer.start()

func _remove_used_tile(texture, player_id):
	var container = top_hud.get_hand_container() if player_id == 1 else bottom_hud.get_hand_container()
	for child in container.get_children():
		if child.has_method("get_texture") and child.get_texture() == texture:
			var empty_tile = EMPTY_BUTTON_SCENE.instance()
			container.remove_child(child)
			child.queue_free()
			container.add_child(empty_tile)
			container.move_child(empty_tile, child.get_index())
			break

func _refill_player_tiles(player_id):
	var container = top_hud.get_hand_container() if player_id == 1 else bottom_hud.get_hand_container()
	for i in range(container.get_child_count()):
		var child = container.get_child(i)
		if not child is UserTile: # More robust check
			var new_tile = USER_BUTTON_SCENE.instance()
			new_tile.player_id = player_id
			new_tile.connect("user_tile_selected", self, "_on_user_tile_selected")
			var texture = _get_random_available_texture()
			if texture:
				new_tile.texture_normal = texture
				if TILE_TEXTURES_DICT.has(texture): TILE_TEXTURES_DICT[texture] -= 1
				container.remove_child(child)
				child.queue_free()
				container.add_child(new_tile)
				container.move_child(new_tile, i)

func _player_played_all_tiles(player_id):
	var container = top_hud.get_hand_container() if player_id == 1 else bottom_hud.get_hand_container()
	for child in container.get_children():
		if child is UserTile: return false
	return true


# --- Scoring & Placement Logic (Unchanged) ---

func _can_place_tile(tile_node, selected_texture):
	var index = grid.get_children().find(tile_node)
	if index == -1: return false
	var columns = 25
	var neighbors = []
	var up = index - columns
	var down  = index + columns
	if up >= 0: neighbors.append(grid.get_child(up))
	if down < grid.get_child_count(): neighbors.append(grid.get_child(down))
	if index % columns != 0: neighbors.append(grid.get_child(index - 1))
	if index % columns != columns - 1: neighbors.append(grid.get_child(index + 1))
	
	var selected_name = selected_texture.resource_path.get_file().get_basename()
	var selected_color = selected_name.split("_")[0]
	var selected_shape = selected_name.split("_")[1]
	
	var has_non_empty_neighbor = false
	for neighbor in neighbors:
		if neighbor.is_set:
			has_non_empty_neighbor = true
			var neighbor_texture = neighbor.base_texture
			var neighbor_name = neighbor_texture.resource_path.get_file().get_basename()
			var neighbor_color = neighbor_name.split("_")[0]
			var neighbor_shape = neighbor_name.split("_")[1]
			if neighbor_color != selected_color and neighbor_shape != selected_shape:
				return false
	return has_non_empty_neighbor

func _load_tile_textures():
	for color in COLORS:
		for shape in SHAPES:
			var path = "res://assets/%s_%s.png" % [color, shape]
			var texture = load(path)
			if texture:
				TILE_TEXTURES.append(texture)
				TILE_TEXTURES_DICT[texture] = 15

func _get_random_available_texture():
	var available = []
	for texture in TILE_TEXTURES_DICT:
		if TILE_TEXTURES_DICT[texture] > 0: available.append(texture)
	if available.empty(): return null
	return available[randi() % available.size()]

func _place_initial_random_tile():
	var children = grid.get_children()
	if children.empty(): return
	var random_tile_index = randi() % children.size()
	var random_tile = children[random_tile_index]
	var random_texture = _get_random_available_texture()
	if random_texture and random_tile:
		if random_tile.set_tile_texture(random_texture):
			if TILE_TEXTURES_DICT.has(random_texture): TILE_TEXTURES_DICT[random_texture] -= 1

func _calculate_score(index, texture):
	# This is the real scoring function, used by both player and AI after placement.
	var columns = 25
	var total_score = 0
	var texture_name = texture.resource_path.get_file().get_basename()
	var selected_color = texture_name.split("_")[0]
	var selected_shape = texture_name.split("_")[1]

	var row_nodes = _get_line_nodes(index, 1)
	var col_nodes = _get_line_nodes(index, columns)

	if row_nodes.size() > 1: total_score += row_nodes.size()
	if col_nodes.size() > 1: total_score += col_nodes.size()
	if total_score == 0 and (row_nodes.size() > 0 or col_nodes.size() > 0): total_score = 1
	
	if row_nodes.size() == 6 and _is_q_line_from_nodes(row_nodes): total_score += 6
	if col_nodes.size() == 6 and _is_q_line_from_nodes(col_nodes): total_score += 6
	
	return total_score

func _get_line_nodes(index, step):
	var line = [grid.get_child(index)]
	for direction in [-1, 1]:
		var i = index + (step * direction)
		while i >= 0 and i < grid.get_child_count():
			if step == 1 and ((direction == 1 and i % 25 == 0) or (direction == -1 and (i + 1) % 25 == 0)): break
			var tile = grid.get_child(i)
			if tile.is_set:
				if direction == 1: line.append(tile)
				else: line.insert(0, tile)
				i += (step * direction)
			else: break
	return line

func _is_q_line_from_nodes(nodes):
	if nodes.size() != 6: return false
	var colors = {}
	var shapes = {}
	for tile in nodes:
		var name = tile.base_texture.resource_path.get_file().get_basename()
		colors[name.split("_")[0]] = true
		shapes[name.split("_")[1]] = true
	return (colors.size() == 1 and shapes.size() == 6) or (colors.size() == 6 and shapes.size() == 1)



const BEAM_WIDTH := 120
const MAX_EXPANSIONS := 5000

var texture_to_id = {}
var id_to_texture = []
var texture_meta = []
var tt_cache = {}

func init_texture_mappings_from_array(texture_array:Array):
	texture_to_id.clear(); id_to_texture.clear(); texture_meta.clear()
	var id = 0
	for tex in texture_array:
		texture_to_id[tex] = id
		id_to_texture.append(tex)
		var name = tex.resource_path.get_file().get_basename()
		texture_meta.append({"color": name.split("_")[0], "shape": name.split("_")[1]})
		id += 1

func start_ai_turn_optimized():
	print("AI (optimized) thinking...")
	shrink_tt_cache() # Periodically clear the cache
	var board = board_to_int_array()
	var hand = hand_to_id_array(bottom_hud.get_hand_container())
	if hand.empty():
		_end_turn_for_player(AI_PLAYER_ID, 0)
		return
	
	var seq = find_best_sequence_beam(board, hand)
	var total_turn_score = 0
	if seq.size() > 0:
		print("AI found %d moves (beam)." % seq.size())
		for move in seq:
			var tex = id_to_texture[move.texture]
			if grid.get_child(move.index).set_tile_texture(tex):
				_remove_used_tile(tex, AI_PLAYER_ID)
				# Recalculate score on the REAL board for accuracy with Q-bonuses
				total_turn_score += _calculate_score(move.index, tex)
	else:
		print("AI passes this turn (no valid beam moves).")

	if _player_played_all_tiles(AI_PLAYER_ID): total_turn_score += 6
	_end_turn_for_player(AI_PLAYER_ID, total_turn_score)

func find_best_sequence_beam(board:PoolIntArray, hand:Array) -> Array:
	var key = board_to_key(board, hand)
	if tt_cache.has(key): return tt_cache[key].sequence.duplicate()

	var candidates = get_candidate_spots_compact(board)
	if candidates.empty():
		var initial_tile = grid.get_children()[grid.get_child_count() / 2]
		candidates.append(initial_tile.get_index())
		if candidates.empty(): return []

	var beam = [{"board": board, "hand": hand, "seq": [], "score": 0}]
	var expansions = 0
	
	for depth in range(min(hand.size(), 6)):
		var next_beam = []
		for state in beam:
			if expansions > MAX_EXPANSIONS: break
			var state_candidates = get_candidate_spots_compact(state.board)
			if state_candidates.empty(): state_candidates = candidates
			
			for h_i in range(state.hand.size()):
				var tid = state.hand[h_i]
				for idx in state_candidates:
					if not can_place_compact(state.board, idx, tid): continue
					
					var s = calculate_score_compact(state.board, idx, tid)
					
					# --- CORRECTED DUPLICATION LOGIC ---
					var nb = state.board # Simple assignment copies a PoolIntArray
					nb[idx] = tid
					
					var nh = state.hand.duplicate(); nh.remove(h_i)
					var nseq = state.seq.duplicate(); nseq.append({"index": idx, "texture": tid, "score": s})
					
					next_beam.append({"board": nb, "hand": nh, "seq": nseq, "score": state.score + s})
					expansions += 1
				if expansions > MAX_EXPANSIONS: break
			if expansions > MAX_EXPANSIONS: break
		
		if next_beam.empty() or expansions > MAX_EXPANSIONS: break
		next_beam.sort_custom(self, "_sort_by_score_desc")
		beam = next_beam.slice(0, BEAM_WIDTH)

	var best_seq = []; var best_score = -1
	for state in beam:
		if state.score > best_score:
			best_score = state.score
			best_seq = state.seq
	
	tt_cache[key] = {"sequence": best_seq.duplicate(), "score": best_score}
	return best_seq
func _sort_by_score_desc(a, b): return a.score > b.score

func board_to_key(board:PoolIntArray, hand:Array) -> String:
	var hand_copy = hand.duplicate(); hand_copy.sort()
	
	# Convert the PoolIntArray to a standard Array.
	var board_as_array = Array(board)
	
	# --- CORRECTED GODOT 4 SYNTAX ---
	# Use the String's join method instead of the Array's.
	var board_string = ",".join(board_as_array)
	var hand_string = ",".join(hand_copy)
	
	return board_string + "|" + hand_string

func shrink_tt_cache(max_entries := 2000):
	if tt_cache.size() > max_entries: tt_cache.clear() # Simple clear is fine

func board_to_int_array() -> PoolIntArray:
	var pa = PoolIntArray(); pa.resize(grid.get_child_count())
	for i in range(grid.get_child_count()):
		var tile = grid.get_child(i)
		pa[i] = texture_to_id.get(tile.base_texture, -1) if tile.is_set else -1
	return pa

func hand_to_id_array(hand_container) -> Array:
	var hand = []
	for tile_node in hand_container.get_children():
		if tile_node is UserTile:
			var tid = texture_to_id.get(tile_node.get_texture(), -1)
			if tid != -1: hand.append(tid)
	return hand

func _neighbors_indexes(i:int, size:int, cols:int) -> Array:
	var res = []
	var up = i - cols; var down = i + cols
	if up >= 0: res.append(up)
	if down < size: res.append(down)
	if i % cols != 0: res.append(i - 1)
	if i % cols != cols - 1: res.append(i + 1)
	return res

func get_candidate_spots_compact(board:PoolIntArray) -> Array:
	var candidates = {}; var size = board.size(); var cols = 25
	for i in range(size):
		if board[i] != -1:
			for nb in _neighbors_indexes(i, size, cols):
				if board[nb] == -1: candidates[nb] = true
	return candidates.keys()

func can_place_compact(board:PoolIntArray, index:int, tid:int) -> bool:
	var meta = texture_meta[tid]
	var has_neighbor = false
	for nb in _neighbors_indexes(index, board.size(), 25):
		var nb_tid = board[nb]
		if nb_tid != -1:
			has_neighbor = true
			var nbm = texture_meta[nb_tid]
			if nbm.color != meta.color and nbm.shape != meta.shape: return false
	return has_neighbor

func calculate_score_compact(board:PoolIntArray, index:int, tid:int) -> int:
	var total = 0
	for step in [1, 25]: # 1 for horizontal, 25 for vertical
		var line_len = 1
		for dir in [-1, 1]:
			var i = index + (step * dir)
			while i >= 0 and i < board.size():
				if step == 1 and ((dir == 1 and i % 25 == 0) or (dir == -1 and (i + 1) % 25 == 0)): break
				if board[i] != -1:
					line_len += 1
					i += (step * dir)
				else: break
		if line_len > 1: total += line_len
	return total if total > 0 else 1

# --- END GAME CHECK & WINNER LOGIC ---

func _check_for_end_of_game() -> bool:
	# 🏁 CASE 0: Score limit (for testing)
	if player_scores[1] >= SCORE_LIMIT or player_scores[2] >= SCORE_LIMIT:
		print("🎯 Score limit reached!")
		return true

	# CASE 1: No more tiles available AND someone emptied their hand
	var no_tiles_left = _no_available_tiles()
	var player_empty = _player_played_all_tiles(1)
	var ai_empty = _player_played_all_tiles(2)

	if no_tiles_left and (player_empty or ai_empty):
		if player_empty:
			player_scores[1] += 6
			print("🎉 Player 1 hand bonus +6!")
		if ai_empty:
			player_scores[2] += 6
			print("🤖 AI hand bonus +6!")
		return true

	# CASE 2: Both players cannot make a valid move
	if not _player_has_valid_move(1) and not _player_has_valid_move(2):
		print("🚫 No valid moves remaining for either player.")
		return true

	return false



func _player_has_valid_move(player_id:int) -> bool:
	var container = top_hud.get_hand_container() if player_id == 1 else bottom_hud.get_hand_container()
	var board = board_to_int_array()
	var hand = hand_to_id_array(container)

	if hand.empty(): 
		return false  # No tiles to play

	for tid in hand:
		for idx in get_candidate_spots_compact(board):
			if can_place_compact(board, idx, tid):
				return true
	return false


func _no_available_tiles() -> bool:
	# If every tile in the global pool is used up
	for texture in TILE_TEXTURES_DICT:
		if TILE_TEXTURES_DICT[texture] > 0:
			return false
	return true


func _end_game():
	print("🏁 Game Over!")
	var player_score = player_scores[1]
	var ai_score = player_scores[2]
	var winner_text = ""

	if player_score > ai_score:
		winner_text = "🎉 You win! Final Score: %d - %d" % [player_score, ai_score]
	elif ai_score > player_score:
		winner_text = "🤖 AI wins! Final Score: %d - %d" % [ai_score, player_score]
	else:
		winner_text = "🤝 It's a tie! Final Score: %d - %d" % [player_score, ai_score]

	_show_winner_popup(winner_text)


func _show_winner_popup(text:String):
	var popup = AcceptDialog.new()
	popup.dialog_text = text + "\n\nClick OK to restart."
	popup.connect("confirmed", self, "_restart_game")
	add_child(popup)
	popup.popup_centered()


func _restart_game():
	get_tree().reload_current_scene()
