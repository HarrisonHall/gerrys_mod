extends Control


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
		Game.Web.request(
			"update_game",
			{
				"username": Game.username,
				"timestamp": OS.get_ticks_msec(),
				"settings": Game.settings
			}
		)

func refresh():
	loaded_player = false
	assert(Game.cur_arena in Resources.arenas, "Uh oh! not a real arena: " + str(Game.cur_arena))
	$MarginContainer/VBoxContainer/Sides/Info/Panel2/MapDescription.text = Resources.arenas[Game.cur_arena]["description"]
	Game.Web.connect(
		"new_data", self, "server_update"
	)

func server_update(obj):
	return

func _on_Button_pressed():
	Resources.load_player()
	Game.get_current_player().respawn(Game.team)
	Game.toggle_mode_menu(false)
	Game.toggle_pause_menu()
	loaded_player = true
	Game.Web.client.disconnect(
		"data_received", self, "server_update"
	)

func load_hub():
	Game.change_lobby(Game.base_lobby, "")


func _on_HubButton_pressed():
	load_hub()
