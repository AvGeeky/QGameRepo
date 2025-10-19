extends PanelContainer

# --- Node References ---
# We get references to the nodes we need to modify.
onready var score_label = $MarginContainer/HBoxContainer/PlayerInfo/ScoreLabel
onready var player_name_label = $MarginContainer/HBoxContainer/PlayerInfo/PlayerName
onready var hand_container = $MarginContainer/HBoxContainer/HandContainer
onready var turn_indicator_label = $MarginContainer/HBoxContainer/PlayerInfo/TurnIndicatorLabel
# --- Public API ---
# These are the functions we'll call from GameBoard.gd.

# Sets the player's name on the HUD.
func set_player_name(p_name):
	player_name_label.text = p_name

# Returns the container where the player's tiles should be added.
func get_hand_container():
	return hand_container
	
# Updates the score with a "pop" animation for better feedback.
func update_score(new_score):
	# A Tween animates properties of a node over time.
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	# 1. Scale up the label for emphasis.
	tween.tween_property(score_label, "rect_scale", Vector2(1.3, 1.3), 0.2)
	
	# 2. Update the text itself. This happens instantly in the middle of the animation.
	#    We use tween_callback to call our helper function.
	tween.tween_callback(self, "_set_score_text", [new_score])
	
	# 3. Scale back down to normal size.
	tween.tween_property(score_label, "rect_scale", Vector2(1.0, 1.0), 0.2)

# Visually indicates whose turn it is by changing the panel's color.
func set_active_turn(is_active):
	var tween = create_tween().set_parallel(true) # Use a parallel tween
	
	# 1. Animate the panel color (the existing effect)
	var panel_target_color = Color("#ffc75f") if is_active else Color.white
	tween.tween_property(self, "modulate", panel_target_color, 0.3)
	
	# 2. Animate the "YOUR TURN" label's visibility
	var label_target_alpha = 1.0 if is_active else 0.0
	tween.tween_property(turn_indicator_label, "modulate:a", label_target_alpha, 0.3)

# --- Private Helper ---
# This function is called by the tween to actually change the label's text.
func _set_score_text(new_score):
	score_label.text = "Score: " + str(new_score)
