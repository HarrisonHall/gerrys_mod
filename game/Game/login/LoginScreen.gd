extends Control


onready var Game = get_tree().get_current_scene()


# Called when the node enters the scene tree for the first time.
func _ready():
	Game.Web.requests.connect("request_completed", self, "login_response")
	#Game.Web.request("connect_user", {"username": "Denny"})


func login_response(result, response_code, headers, body):
	var data = JSON.parse(body.get_string_from_utf8()).result
	if "login_status" in data:
		if data["login_status"] == true:
			$Panel/TextBox.text += "Logged in\n"
			Game.username = data["username"]
		else:
			$Panel/TextBox.text += "Unable to log in\n"
	else:
		print("[Login] Wrong packet")


func _on_login_button_pressed():
	Game.Web.request(
		"connect_user", 
		{
			"username": $LoginPanel/username.text,
			"password": $LoginPanel/password.text
		}
	)
