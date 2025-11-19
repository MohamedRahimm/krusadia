extends Node2D
func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")

#func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	#if response_code == 200:
		#var text := body.get_string_from_utf8()
		#print("API Response:", text)
	#else:
		#print("Request failed. HTTP code:", response_code)
#
#func _on_leaderboard_button_pressed() -> void:
	##get_tree().change_scene_to_file("res://scenes/level_1.tscn")
	#var url := "/api/leaderboard"
#
	#var http := HTTPRequest.new()
	#add_child(http)
#
	#http.request_completed.connect(_on_request_completed)
#
	#var err := http.request(url, [], HTTPClient.METHOD_GET)
	#if err != OK:
		#print("Failed to send leaderboard request: %s" % err)
@onready var http_request= $HTTPRequest
func truncate_after_net(url: String) -> String:
	var pos = url.find(".net")  # find first occurrence of ".net"
	if pos == -1:
		return url  # no .net found, return original
	return url.substr(0, pos + 4)  # include ".net" (4 characters)
	
func _ready():
	var document = JavaScriptBridge.get_interface("document")
	var trunc = truncate_after_net(document.URL)+"/api/leaderboard"
	http_request.request_completed.connect(_on_request_completed)
	http_request.request(trunc)

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Request failed with code: ", response_code)
		return

	var text = body.get_string_from_utf8()
	print("text")
	print(text)
	#var json = JSON.parse_string(text)
#
	#if json == null:
		#print("Failed to parse JSON: ", text)
		#return
#
	## json is a Dictionary: { "success": true, "message": "leaderboard works" }
	#print("Success:", json.get("success"))
	#print("Message:", json.get("message"))
