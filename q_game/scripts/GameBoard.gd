extends Control

const BUTTON_SCENE = preload("res://scenes/EmptyTile.tscn")

func _ready():
	var grid = $GridContainer
	grid.columns = 25  # Make sure columns is set here
	for i in range(25 * 25):  # 625 buttons total
		var btn = BUTTON_SCENE.instance()
		grid.add_child(btn)

