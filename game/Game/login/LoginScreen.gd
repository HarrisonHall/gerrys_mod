extends Control


onready var Game = get_tree().get_current_scene()
onready var login_box = $Margin/Menu/RightHalf/PanelContainer/login_box
onready var info_box = $Margin/Menu/LeftHalf/InfoBox


# Called when the node enters the scene tree for the first time.
func _ready():
	Game.Web.connect("new_data", self, "login_response_s")
	Game.Web.connect("new_data", self, "ping_rate")

var fired = false
func login_response(result, response_code, headers, body):
	if fired:
		return
	if response_code < 200 or response_code >= 300:
		info_box.text += "Server is unavailable\n"
		return
	var data = JSON.parse(body.get_string_from_utf8()).result
	if "login_status" in data:
		if data["login_status"] == true:
			login_box.visible = false
			info_box.text += "Logged in\n"
			Game.username = data["username"]
			Game.load_arena(data["updates"]["new_arena"])
			#Game.Web.requests.disconnect("login_response")
			fired = true
		else:
			info_box.text += "Unable to log in\n"
	else:
		print("[Login] Wrong packet")

func login_response_s(obj):
	if fired:
		return
	var data = obj
	if "login_status" in data:
		if data["login_status"] == true:
			login_box.visible = false
			info_box.text += "Logged in\n"
			Game.username = data["username"]
			Game.load_arena(data["updates"]["new_arena"])
			#Game.Web.requests.disconnect("login_response")
			fired = true
		else:
			info_box.text += "Unable to log in\n"
	else:
		print("[Login] Wrong packet")

func _on_login_button_pressed():
	if Game.singleplayer:
		login_box.visible = false
		#Game.load_arena("dg_worstmap")
		Game.load_arena("DebugArea")
		return
	Game.Web.request(
		"connect_user", 
		{
			"username": login_box.get_node("username").text,
			"password": login_box.get_node("password").text
		}
	)

var server_choices = {
	0: "ws://gerrys-mod-demo.herokuapp.com/ping",
	1: "ws://127.0.0.1:8000/ping",
	2: "singleplayer"
}
func _on_serverbutton_item_selected(index):
	if index in server_choices:
		#Game.Web.url = server_choices[index]
		if server_choices[index] != "singleplayer":
			Game.Web.change_server(server_choices[index])
		print("Changed server url to ", Game.Web.url)
		if index == 2: # singleplayer
			Game.singleplayer = true
	else:
		print("Invalid server option: ", index)

func _on_ExitButton_pressed():
	get_tree().quit()

var last_times = []
var r_rate = 0
func ping_rate(data):
	last_times.append(OS.get_ticks_msec())
	if len(last_times) > 100:
		last_times.pop_front()
	if len(last_times) > 1:
		r_rate = (float(len(last_times)) / float((last_times[-1] - last_times[0]))) * 1000
		$Margin/Menu/RightHalf/Spacing1/PingLabel.text = str(r_rate) + " packets per second"





func _on_MSSlider_value_changed(value):
	var player = Game.get_node("Map/Players/"+Game.username)
	if player != null:
		player.CAM_SENSITIVITY = value
