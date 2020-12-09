extends Control


onready var Game = get_tree().get_current_scene()

var loaded_player = false
var max_server_delta = 0.17
var server_delta = max_server_delta

# Called when the node enters the scene tree for the first time.
func _ready():
	refresh()

func _process(delta):
	server_delta -= delta
	if server_delta < 0 and not loaded_player:
		server_delta = max_server_delta
		Game.Web.request("",{
			"username": Game.username,
			"timestamp": OS.get_ticks_msec(),
			"settings": Game.settings
		})

func refresh():
	loaded_player = false
	#$MarginContainer/VBoxContainer/Sides/Info/Panel2/MapDescription.text = Game.arenas[Game.cur_arena]["description"]
	Game.Web.connect(
		"new_data", self, "server_update"
	)

func server_update(obj):
	return

func on_start():
	Game.load_player()
	Game.get_current_player().respawn(Game.team)
	Game.toggle_mode_menu(false)
	Game.toggle_pause_menu()
	loaded_player = true
#	Game.Web.client.disconnect(
#		"data_received", self, "server_update"
#	)
