extends Control

const BUTTON_SCENE = preload("res://scenes/EmptyTile.tscn")

func _ready():
	# Get the GridContainer and ScrollContainer nodes
	var grid = $ScrollContainer/GridContainer
	var scroll = $ScrollContainer  # Assuming you've added a ScrollContainer node in the scene

	# Set GridContainer to a fixed size with a margin of 200px from top and bottom
	var available_height = 600 # The space available for the grid
	var available_width = 1000

	grid.rect_min_size = Vector2(available_width, available_height)
	
	# We are fixing rows to be 25, and columns to 25.
	var rows = 25  # Fixed number of rows
	var columns = 25  # Fixed number of columns

	# Calculate the total height of the grid
	var total_height = rows * 60  # Each tile is 60px high
	var total_width = columns * 60  # Each tile is 60px wide

	# Loop to create and add tiles to the grid
	for i in range(rows * columns):
		var btn = BUTTON_SCENE.instance()
		grid.add_child(btn)

	# Set the grid size dynamically to handle scrolling and ensure it fits within the viewport's available space
	grid.rect_min_size = Vector2(total_width, total_height)  # Set width and height based on rows and columns

	# ScrollContainer's size should match the available space for the grid.
	scroll.rect_min_size = Vector2(available_width, available_height)
