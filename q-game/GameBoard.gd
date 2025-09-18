extends Control

const GRID_SIZE = 25
const CELL_SCENE = preload("res://EmptyCell.tscn")

func _ready():
	var grid = $GridContainer
	grid.columns = GRID_SIZE
	for i in GRID_SIZE * GRID_SIZE:
		var cell = CELL_SCENE.instantiate()
		grid.add_child(cell)
