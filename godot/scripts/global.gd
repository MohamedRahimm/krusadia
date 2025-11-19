extends Node

var gems_collected: int = 0
const tile_size = 64
const SPRITE_SHEET = preload("uid://0r7ygv2g2km3")

enum TrapTypes { SPIKES, EXIT, ENTRANCE, LEVER, CHEST, BARREL }
enum WallTypes { WALL1, WALL2, WALL3, WALL4, WALL5, WALL6, WALL7, WALL8, WALL9, WALL10, WALL11, WALL12 }
var trap_sprite_regions:Dictionary = {
	TrapTypes.SPIKES: Rect2(0, 128, tile_size, tile_size),
	TrapTypes.EXIT: Rect2(64, 128, tile_size, tile_size),
	TrapTypes.ENTRANCE: Rect2(128, 128, tile_size, tile_size),
	TrapTypes.LEVER: Rect2(256.0, 128, tile_size, tile_size),
	TrapTypes.CHEST: Rect2(320.0, 128, tile_size, tile_size),
	TrapTypes.BARREL: Rect2(0, 192, tile_size, tile_size),
}
var wall_sprite_regions:Dictionary = {
	WallTypes.WALL1: Rect2(0, 0, tile_size, tile_size),
	WallTypes.WALL2: Rect2(64, 0, tile_size, tile_size),
	WallTypes.WALL3: Rect2(128, 0, tile_size, tile_size),
	WallTypes.WALL4: Rect2(192, 0, tile_size, tile_size),
	WallTypes.WALL5: Rect2(256, 0, tile_size, tile_size),
	WallTypes.WALL6: Rect2(320, 0, tile_size, tile_size),
	WallTypes.WALL7: Rect2(0, 64, tile_size, tile_size),
	WallTypes.WALL8: Rect2(64, 64, tile_size, tile_size),
	WallTypes.WALL9: Rect2(128, 64, tile_size, tile_size),
	WallTypes.WALL10: Rect2(192, 64, tile_size, tile_size),
	WallTypes.WALL11: Rect2(256, 64, tile_size, tile_size),
	WallTypes.WALL12: Rect2(320, 64, tile_size, tile_size),
}


func _ready():
	pass


func _input(event):
	if event.is_action_pressed("return_to_main_menu"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F11:
			full_screen()


func full_screen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
