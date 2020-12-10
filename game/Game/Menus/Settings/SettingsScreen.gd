extends Control


onready var Game = get_tree().get_current_scene()

var set_graphics = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(delta):
	if not set_graphics:
		_on_VisualOptions_item_selected(1)
		set_graphics = true


func _on_MSSlider_value_changed(value):
	var player = Game.get_current_player()
	if player != null:
		player.CAM_SENSITIVITY = value


var server_choices = {
	0: "ws://gerrys-mod-demo.herokuapp.com/ping",
	1: "ws://127.0.0.1:8000/ping",
	2: "singleplayer"
}
func _on_serverbutton_item_selected(index):
	if index in server_choices:
		if server_choices[index] != "singleplayer":
			Game.Web.change_server(server_choices[index])
		print("Changed server url to ", Game.Web.url)
		if index == 2: # singleplayer
			Game.singleplayer = true
	else:
		print("Invalid server option: ", index)


func _on_VisualOptions_item_selected(index):
	var view = Game.GameViewport
	var new_size = Vector2()
	if index == 0:
		new_size = Vector2(640, 480)
		view.set_msaa(0)
	if index == 1:
		new_size = Vector2(960, 540)
		view.set_msaa(0)
	if index == 2:
		new_size = Vector2(1280, 720)
		view.set_msaa(2)
	if index == 3:
		new_size = Vector2(1920, 1080)
		view.set_msaa(3)
	print("is same?: ",get_tree().get_root() == get_viewport())
	if new_size != Vector2():
		print("Emitting change!")
		#view.set_size_override_stretch(true)
		#view.set_size_override(true, new_size)
		view.set_size(new_size)
		Events.emit_signal("viewport_changed")
