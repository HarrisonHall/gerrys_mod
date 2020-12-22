extends Control


func _ready():
	pass # Replace with function body.

func clear_text():
	$ModContainer/ModInput.text = ""

func add_info(info):
	$ModContainer/ModInfo.text = info
	Events.notify("Mod Menu", info, 4)

func _on_ModInput_text_entered(new_text):
	_on_ModConfirm_pressed()

func _on_ModConfirm_pressed():
	var text = $ModContainer/ModInput.text
	var words = text.split(" ", false)
	if len(words) == 0:
		return
	
	if words[0] == "ping":
		var new_val = float(words[1])
		for person in Game.Players.get_children():
			person.SERVER_DELTA = new_val
		add_info("Set ping to " + str(new_val))
		clear_text()
	if words[0] == "model":
		var new_model = words[1]
		var player = null
		if Game.singleplayer:
			player = Game.Players.get_children()[0]
		else:
			player = Game.get_current_player()
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
			"timestamp": OS.get_ticks_msec(),
			"settings": Game.settings
		})
	if words[0] == "respawn":
		var p = Game.get_current_player()
		if p:
			p.respawn()
		clear_text()
		add_info("Respawned player")
	if words[0] == "make":
		if len(words) == 1:
			print("ERROR: No object type")
			return
		var type = words[1]
		if not (type in Resources.object_types):
			print("ERROR: No object of type ", words[1])
			return
		var b = Resources.make_obj(type, "")
		if b == null:
			print("Error creating object ")
			return
		print("created " + b.name)
		var btrans = b.get_global_transform()
		btrans.origin = Game.get_current_player().get_global_transform().origin
		btrans.origin.y += 3
		b.set_global_transform(btrans)
		b.send_update()
		clear_text()
	if words[0] == "team":
		if len(words) == 1:
			print("ERROR: No team number")
			return
		var team = int(words[1])
		if team == 0:
			team = 1
		Game.team = team
		add_info("Set team to "+ str(team))
		clear_text()
	if words[0] == "map":
		if len(words) == 1:
			print("ERROR: No map name")
			return
		if not (words[1] in Resources.arenas):
			print("ERROR: Invalid arena")
			return
		if Game.singleplayer:
			Game.clear_gameplay()
			Game.load_arena(words[1])
			Game.load_player()
			Game.get_current_player().respawn(Game.team)
		else:
			print("requested update")
			Game.Web.request(
				"server_settings",
				{
					"username": Game.username,
					"map": words[1],
					"settings": Game.settings
				}
			)
		add_info("Set arena to "+ str(words[1]))
		clear_text()
	if words[0] == "noclip":
		var p = Game.get_current_player()
		if Game.get_current_player():
			p.noclip()
			add_info("Set noclip to "+ str(p._noclip))
		clear_text()







