# PlacedItem.gd
extends TextureRect
class_name PlacedItem

# Signal to notify the LevelEditor that this item has been picked up.
# It will send itself as an argument.
signal picked_up(item)

# These will store the item's identity.
var item_category: String
var item_type_enum: int

func _gui_input(event: InputEvent):
	# Check if the user pressed the left mouse button down on this item.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# Emit the signal and consume the event so nothing else processes this click.
		emit_signal("picked_up", self)
		get_viewport().set_input_as_handled()
