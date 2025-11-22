extends Node2D
func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")

@onready var http_request=$HTTPRequest

func truncate_after_net(url: String) -> String:
	var pos = url.find(".net")  # find first occurrence of ".net"
	if pos == -1:
		return url  # no .net found, return original
	return url.substr(0, pos + 4)  # include ".net" (4 characters)

func _on_leaderboard_button_pressed() -> void:
	var document = JavaScriptBridge.get_interface("document")
	var trunc = truncate_after_net(document.URL) + "/api/leaderboard"
	http_request.request_completed.connect(_on_request_completed)
	http_request.request(trunc, [], HTTPClient.METHOD_GET)


func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Request failed with code: ", response_code)
		return
	var text = body.get_string_from_utf8()
	print("text")
	print(text)


func _on_post_button_pressed() -> void:
	var document = JavaScriptBridge.get_interface("document")
	var trunc = truncate_after_net(document.URL) + "/internal/menu/post-create"
	http_request.request(trunc, [], HTTPClient.METHOD_POST)
