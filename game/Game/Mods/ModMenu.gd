extends Control


onready var Game = get_tree().get_current_scene()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func clear_text():
	$MarginContainer/VBoxContainer/Input.text = ""

func add_info(info):
	$MarginContainer/VBoxContainer/Info.text += "\n" + info

func _on_Button_pressed():
	var text = $MarginContainer/VBoxContainer/Input.text.to_lower()
	var words = text.split(" ", false)
	if len(words) == 0:
		return
	
	if words[0] == "ping":
		var new_val = float(words[1])
		for person in Game.get_node("Map/Players").get_children():
			person.SERVER_DELTA = new_val
		add_info("Set ping to " + str(new_val))
		clear_text()
	if words[0] == "model":
		var new_model = words[1]
		var player = null
		if Game.singleplayer:
			player = Game.get_node("Map/Players").get_children()[0]
		else:
			player = Game.get_node("Map/Players/"+Game.username)
		player.set_model(new_model)
		add_info("Set model to " + new_model)
		clear_text()
		Game.Web.request("update_info", {
			"username": Game.username,
			"update": {
				"people": {
					Game.username : {
						"model": new_model
					}
				}
			}, 
			"timestamp": OS.get_ticks_msec()
		})
	if words[0] == "respawn":
		var p = Game.get_player()
		if p:
			p.respawn()
		clear_text()
		add_info("Respawned player")
	if words[0] == "make":
		var name_should_be = Game.username + "_thing_" + str(len(Game.get_node("Map/Objects").get_children())+1)
		if Game.get_node("Map/Objects/"+name_should_be):
			print("Thing exists, skipping...")
		var b = Game.object_types.get(words[1].to_lower(), Game.object_types["barrell"]).instance()
		print("created " + b.name)
		Game.get_node("Map/Objects").add_child(b)
		var btrans = b.get_global_transform()
		btrans.origin = Game.get_node("Map/Players/"+Game.username).get_global_transform().origin
		btrans.origin.y += 3
		b.set_global_transform(btrans)
		b.set_name(name_should_be)
		#b.set_name(b.get_name().replace("@", ""))
		b.send_update()
		clear_text()
