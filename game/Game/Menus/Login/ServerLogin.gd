extends Control


var logged_in = false

onready var Game = get_tree().get_current_scene()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if not logged_in:
		$Login.visible = true
		$Logout.visible = false
	else:
		$Login.visible = false
		$Logout.visible = true

var server_choices = {
	0: "ws://gerrys-mod-demo.herokuapp.com/ping",
	1: "ws://127.0.0.1:8000/ping",
	2: "singleplayer"
}

func _on_serverchoice_item_selected(index):
	print("Changed server url to ", Game.Web.url)
	if server_choices[index] != "singleplayer":
		Game.Web.change_server_url(server_choices[index])
	Game.singleplayer = false
	if index == 2: # singleplayer
		Game.singleplayer = true

func _on_username_text_entered(new_text):
	_on_LoginButton_pressed()

func _on_password_text_entered(new_text):
	_on_LoginButton_pressed()

func _on_LoginButton_pressed():
	if Game.singleplayer:
		Game.load_arena("fp_debugarea")
		logged_in = true
		Game.toggle_pause_menu(true)
		Game.toggle_mode_menu(true)
		return
	Game.Web.connect_to_server()
	Game.Web.client.connect(
		"connection_established", self, "send_login_request"
	)
	Game.Web.client.connect(
		"data_received", self, "received_login_data"
	)
	Game.Web.client.connect(
		"connection_closed", self, "conn_closed"
	)
	Game.Web.client.connect(
		"connection_error", self, "conn_closed"
	)

func _on_LogoutButton_pressed():
	logged_in = false
	Game.Web.client.disconnect_from_host()
	var old_arena = Game.Arena.get_node("ARENA")
	if old_arena != null:
		old_arena.name = "OLD_ARENA"
		old_arena.queue_free()
	Game.clear_gameplay()
	var menu_background = Game.menu_background_pck.instance()
	menu_background.name = "ARENA"
	Game.Arena.add_child(menu_background)
	menu_background.name = "ARENA"
	Game.toggle_pause_menu(true)
	Game.toggle_mode_menu(false)

func send_login_request(proto = ""):
	print("Sending login")
	Game.Web.request(
		"connect_user", 
		{
			"username": $Login/username.text,
			"password": $Login/password.text,
			"lobby": "DEFAULT"
		}
	)

func conn_closed(was_clean = false):
	print("Handling connection error...")
	logged_in = false
	_on_LogoutButton_pressed()

func received_login_data():
	var data_good = false
	var raw = Game.Web.client.get_peer(1).get_packet().get_string_from_utf8()
	var res = JSON.parse(raw)
	var data = res.result
	if "login_status" in data:
		if data["login_status"] == true:
			logged_in = true
			Game.PauseMenu.SessionInfo.add_info("Logged in")
			Game.Web.client.disconnect(
				"data_received", self, "received_login_data"
			)
			Game.username = data["username"]
			logged_in = true
			Game.Web.connect("new_data", Game, "update_players_s")
			Game.update_players_s(data)
		else:
			Game.PauseMenu.SessionInfo.add_info("Unable to log in")
