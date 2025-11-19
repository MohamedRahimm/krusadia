# LevelEditor.gd
extends Control
class_name LevelEditor

@onready var background_grid: GridContainer = $HBoxContainer/LevelArea/BackgroundGrid
@onready var placement_grid: Control = $HBoxContainer/LevelArea/PlacementGrid
@onready var trash_area: TextureRect = $HBoxContainer/LevelArea/TrashArea


# Variables to manage the current drag operation
var current_draggable_element: TextureRect = null
var original_dragged_item: PlacedItem = null
var ghost_preview: TextureRect = null
var current_drag_data: Dictionary = {} # Stores info about what we're dragging
const mouse_offset:Vector2 = Vector2(Global.tile_size/2, Global.tile_size/2)

func _ready() -> void:
	# --- Connect Trap Buttons ---
	var trap_buttons = get_tree().get_nodes_in_group("trap_button")
	for button: TextureButton in trap_buttons:
		var trap_type_string = button.name.to_upper()
		if Global.TrapTypes.has(trap_type_string):
			var trap_type_enum = Global.TrapTypes[trap_type_string]
			# Bind the category ("trap") and the specific enum value
			button.button_down.connect(start_drag.bind("trap", trap_type_enum))

	# --- Connect Wall Buttons ---
	var wall_buttons = get_tree().get_nodes_in_group("wall_button")
	for button: TextureButton in wall_buttons:
		var wall_type_string = button.name.to_upper()
		if Global.WallTypes.has(wall_type_string):
			var wall_type_enum = Global.WallTypes[wall_type_string]
			# Bind the category ("wall") and the specific enum value
			button.button_down.connect(start_drag.bind("wall", wall_type_enum))

# This single function starts a drag for ANY object type
func start_drag(item_category: String, item_type_enum: int):
	if current_draggable_element: return

	# Store the data about the object we are dragging
	current_drag_data = {
		"category": item_category,
		"type": item_type_enum
	}

	# Create the visual elements for the drag
	current_draggable_element = create_draggable_element(item_category, item_type_enum)
	add_child(current_draggable_element) # Add to the top-level editor node

	ghost_preview = create_draggable_element(item_category, item_type_enum)
	ghost_preview.modulate.a = 0.5 # Make it semi-transparent
	add_child(ghost_preview)


# Generalized function to create a draggable element
func create_draggable_element(category: String, type_enum: int) -> TextureRect:
	var region_dict: Dictionary
	if category == "trap":
		region_dict = Global.trap_sprite_regions
	elif category == "wall":
		region_dict = Global.wall_sprite_regions
	else:
		return TextureRect.new() # Return empty if category is unknown

	var new_draggable := TextureRect.new()
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = Global.SPRITE_SHEET
	atlas_texture.region = region_dict[type_enum]
	new_draggable.texture = atlas_texture
	
	new_draggable.custom_minimum_size = background_grid.cell_size
	new_draggable.pivot_offset = new_draggable.size / 2.0
	new_draggable.mouse_filter = MOUSE_FILTER_IGNORE
	
	return new_draggable


func _process(delta: float) -> void:
	if current_draggable_element:
		# The element you are actively dragging follows the mouse exactly
		current_draggable_element.global_position = get_global_mouse_position() - mouse_offset
		
		if ghost_preview:
			# 1. Get the grid coordinate under the mouse
			var grid_coords = background_grid.world_to_grid_coords(get_global_mouse_position())
			
			# 2. Check if it's a valid spot
			if background_grid.is_within_bounds(grid_coords):
				ghost_preview.visible = true
				# 3. Snap the ghost's position to the grid
				ghost_preview.global_position = background_grid.grid_coords_to_world(grid_coords)
			else:
				ghost_preview.visible = false


func _input(event: InputEvent) -> void:
	if current_draggable_element and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		var mouse_pos = get_global_mouse_position()
		# --- 1. TRASH AREA LOGIC ---
		if trash_area.get_global_rect().has_point(mouse_pos):
			print("Item dropped in trash.")
			# If we were moving an existing item, delete the original.
			if original_dragged_item:
				original_dragged_item.queue_free()
			# The draggable visuals are cleaned up below.
		
		# --- 2. GRID DROP LOGIC ---
		else:
			var grid_coords = background_grid.world_to_grid_coords(mouse_pos)
			if background_grid.is_within_bounds(grid_coords):
				
				# Check if the target cell is empty.
				if background_grid.grid_data[grid_coords.y][grid_coords.x] == null:
					
					# --- CASE A: MOVING AN EXISTING ITEM ---
					if original_dragged_item:
						print("Moving item to ", grid_coords)
						# Un-hide the original item and move it to the new spot.
						original_dragged_item.visible = true
						original_dragged_item.global_position = background_grid.grid_coords_to_world(grid_coords)
						# Update the grid data at the new location.
						background_grid.grid_data[grid_coords.y][grid_coords.x] = original_dragged_item
					
					# --- CASE B: PLACING A NEW ITEM ---
					else:
						# 1. Create the final object to be placed using our new class.
						var placed_item = PlacedItem.new() # <-- Use PlacedItem now
						placed_item.texture = current_draggable_element.texture
						placed_item.custom_minimum_size = background_grid.cell_size
						placed_item.mouse_filter = MOUSE_FILTER_PASS

						# Store its identity
						placed_item.item_category = current_drag_data.category
						placed_item.item_type_enum = current_drag_data.type

						# --- THIS IS THE CRUCIAL CONNECTION ---
						placed_item.picked_up.connect(_on_item_picked_up)

						# 2. Add it to the PLACEMENT_GRID node
						placement_grid.add_child(placed_item)
						placed_item.global_position = background_grid.grid_coords_to_world(grid_coords)

						# 3. Update the data array
						background_grid.grid_data[grid_coords.y][grid_coords.x] = placed_item
						print("Placing new item at ", grid_coords)
						
				else:
					print("Cell is occupied. Cancelling drop.")
					# If we were moving, restore the original item.
					if original_dragged_item:
						original_dragged_item.visible = true
						var original_coords = background_grid.world_to_grid_coords(original_dragged_item.global_position)
						background_grid.grid_data[original_coords.y][original_coords.x] = original_dragged_item
			else:
				# Dropped outside grid and not in trash - cancel the move.
				if original_dragged_item:
					original_dragged_item.visible = true
					var original_coords = background_grid.world_to_grid_coords(original_dragged_item.global_position)
					background_grid.grid_data[original_coords.y][original_coords.x] = original_dragged_item

		# --- 3. UNIVERSAL CLEANUP ---
		if current_draggable_element: current_draggable_element.queue_free()
		if ghost_preview: ghost_preview.queue_free()
		
		current_draggable_element = null
		ghost_preview = null
		current_drag_data = {}
		original_dragged_item = null # IMPORTANT: Reset the move state


func _on_item_picked_up(item: PlacedItem):
	# Don't allow picking up a new item if we're already dragging something.
	if current_draggable_element:
		return

	# --- ENTER "MOVING" STATE ---
	print("Picked up existing item: ", item.item_category)

	# 1. Store a reference to the original item.
	original_dragged_item = item

	# 2. Find its coordinates and clear that data from the grid.
	var grid_coords = background_grid.world_to_grid_coords(item.global_position)
	if background_grid.is_within_bounds(grid_coords):
		background_grid.grid_data[grid_coords.y][grid_coords.x] = null

	# 3. Create the drag visuals (just like in start_drag).
	current_drag_data = {
		"category": item.item_category,
		"type": item.item_type_enum
	}
	current_draggable_element = create_draggable_element(item.item_category, item.item_type_enum)
	add_child(current_draggable_element)

	ghost_preview = create_draggable_element(item.item_category, item.item_type_enum)
	ghost_preview.modulate.a = 0.5
	add_child(ghost_preview)

	# 4. Hide the original item. It will be moved or deleted on drop.
	item.visible = false
