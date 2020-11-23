extends Spatial


var login_screen_pck = preload("res://Game/login/LoginScreen.tscn")


# arenas
var menu_background_pck = preload("res://Game/Areas/Backgrounds/MenuBackground.tscn")
var arenas = {
	"DebugArea": preload("res://Game/Areas/Debug/DebugArea.tscn"),
	"dg_worstmap": preload("res://Game/Areas/Arena/dg_worstmap/dg_worstmap.tscn")
}
var person = preload("res://Game/Characters/Players/Person.tscn")


onready var Web = $Web



# Game vars
var username = "?"
var singleplayer = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# load background
	var menu_background = menu_background_pck.instance()
	menu_background.name = "ARENA"
	$Map/Arena.add_child(menu_background)
	# load login screen
	var login_screen = login_screen_pck.instance()
	$UI.add_child(login_screen)
	OS.min_window_size = Vector2(640, 360)


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if $UI.visible:
			$UI.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			$UI.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func load_arena(arena_name):
	var old_arena = $Map/Arena.get_node("ARENA")
	if old_arena != null:
		old_arena.name = "OLD_ARENA"
		old_arena.queue_free()
	var new_arena = arenas[arena_name].instance()
	new_arena.name = "ARENA"
	$Map/Arena.add_child(new_arena)
	var new_player = person.instance()
	$Map/Players.add_child(new_player)
	new_player.get_node("CameraHinge/Camera").current = true
	new_player.name = username
	#Web.requests.connect("request_completed", self, "update_players")
	Web.connect("new_data", self, "update_players_s")
	new_player.respawn()

var last_timestamp = -1
func update_players(result, response_code, headers, body):
	if response_code < 200 or response_code >= 300:
		return
	var data = JSON.parse(body.get_string_from_utf8()).result
	
	# ensure new packet
	var new_timestamp = data.get("timestamp", -2)
	if new_timestamp < last_timestamp:
		return
	last_timestamp = new_timestamp
	
	# update players
	for player in data.get("updates", {}).get("players", {}):
		print("updating: ", player)
		var p_data = data["updates"]["players"][player]
		if player == username:  # Skip self
			continue
		var p_obj = $Map/Players.get_node(player)
		if p_obj == null:
			print("Making player: ", player)
			p_obj = person.instance()
			p_obj.name = player
			$Map/Players.add_child(p_obj)
		var mom = p_data.get("momentum", [0, 0, 0])
		var pos = p_data.get("position", [0, 0, 0])
		var rot = p_data.get("rotation", [0, 0, 0])
		var t = OS.get_unix_time()
		p_obj.set_mom(Vector3(mom[0], mom[1], mom[2]), new_timestamp)
		p_obj.set_pos(Vector3(pos[0], pos[1], pos[2]), new_timestamp)
		p_obj.set_rot(Vector3(rot[0], rot[1], rot[2]), new_timestamp)

func update_players_s(obj):
	var data = obj
	
	# ensure new packet
	var new_timestamp = data.get("timestamp", -2)
	if new_timestamp < last_timestamp:
		return
	last_timestamp = new_timestamp
	
	# update players
	for player in data.get("updates", {}).get("players", {}):
		var p_data = data["updates"]["players"][player]
		if player == username:  # Skip self
			continue
		var p_obj = $Map/Players.get_node(player)
		if p_obj == null:
			print("Making player: ", player)
			p_obj = person.instance()
			p_obj.name = player
			$Map/Players.add_child(p_obj)
		var mom = p_data.get("momentum", [0, 0, 0])
		var pos = p_data.get("position", [0, 0, 0])
		var rot = p_data.get("rotation", [0, 0, 0])
		var t = OS.get_unix_time()
		p_obj.set_mom(Vector3(mom[0], mom[1], mom[2]), new_timestamp)
		p_obj.set_pos(Vector3(pos[0], pos[1], pos[2]), new_timestamp)
		p_obj.set_rot(Vector3(rot[0], rot[1], rot[2]), new_timestamp)
