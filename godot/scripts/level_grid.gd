# LevelGrid.gd
extends GridContainer

# Export these so you can easily change them in the Inspector
@export var grid_size: Vector2i = Vector2i(11, 7)
@export var cell_size: Vector2 = Vector2(Global.tile_size, Global.tile_size)

# 2D array to keep track of what's in each cell.
var grid_data: Array = []
@export var color_one := Color("333333") # Dark Gray
@export var color_two := Color("444444") # Lighter Gray

func _ready():
	# Resize the 2D array to match our grid dimensions
	grid_data.resize(grid_size.y)
	columns = grid_size.x
	for y in grid_size.y:
		grid_data[y] = []
		grid_data[y].resize(grid_size.x)
		grid_data[y].fill(null) # Start with all cells empty
	
	# Generate the visual placeholder cells
	generate_cells()

func generate_cells():
	# Loop through with x and y coordinates to determine the color
	for y in grid_size.y:
		for x in grid_size.x:
			var cell = ColorRect.new()
			cell.custom_minimum_size = cell_size
			cell.mouse_filter = MOUSE_FILTER_IGNORE
			
			# The checkerboard logic: if (x+y) is even, use color one, else use color two.
			if (x + y) % 2 == 0:
				cell.color = color_one
			else:
				cell.color = color_two
				
			add_child(cell)

# --- HELPER FUNCTIONS ---

# Converts mouse position to grid coordinates
func world_to_grid_coords(world_position: Vector2) -> Vector2i:
	var local_pos = world_position - global_position
	var grid_coords = Vector2i(local_pos / cell_size)
	return grid_coords

# Converts grid coordinates (e.g., 2, 3) back to a global world position (snapped)
func grid_coords_to_world(grid_coords: Vector2) -> Vector2:
	var local_pos = grid_coords * cell_size
	return global_position + local_pos

# Checks if a given coordinate is within the grid bounds
func is_within_bounds(grid_coords: Vector2i) -> bool:
	return grid_coords.x >= 0 and grid_coords.x < grid_size.x and \
		   grid_coords.y >= 0 and grid_coords.y < grid_size.y
