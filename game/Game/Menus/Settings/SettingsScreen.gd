extends Control


onready var Game = get_tree().get_current_scene()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


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
