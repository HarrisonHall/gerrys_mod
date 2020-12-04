extends Spatial


var login_screen_pck = preload("res://Game/login/LoginScreen.tscn")


# arenas
var menu_background_pck = preload("res://Game/Areas/Backgrounds/MenuBackground.tscn")
var arenas = {
	"DebugArea": preload("res://Game/Areas/Debug/DebugArea.tscn"),
	"dg_worstmap": preload("res://Game/Areas/Arena/dg_worstmap/dg_worstmap.tscn")
}
var object_types = {
	"barrell": preload("res://Game/Objects/GameObjects/Barrell/Barrell.tscn"),
	"gun": preload("res://Game/Objects/GameObjects/Guns/Gun.tscn"),
	"HeldObject": preload("res://Game/Objects/GameObjects/Guns/HeldObject.tscn"),
	"bullet": preload("res://Game/Objects/GameObjects/Bullets/Bullet.tscn"),
}
var person = preload("res://Game/Characters/Players/Person.tscn")

onready var Web = $Web
var menu_up = true

# Game vars
var username = "DEFAULT_USER"
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
		if menu_up:
			$UI.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			menu_up = false
		else:
			$UI.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			menu_up = true

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
	#new_player.get_node("CameraHinge/Camera").current = true
	new_player.name = username
	#Web.requests.connect("request_completed", self, "update_players")
	Web.connect("new_data", self, "update_players_s")
	new_player.respawn()

var last_timestamp = -1
func update_players_s(data):
	if not data:
		return
	
	# ensure new packet
	var new_timestamp = data.get("timestamp", -2)
	if new_timestamp < last_timestamp:
		return
	last_timestamp = new_timestamp
	
	# update players
	for player in data.get("updates", {}).get("players", {}):
		var p_data = data["updates"]["players"][player]
		var p_obj = $Map/Players.get_node(player)
		if player == username:  # Skip self
			#p_obj.update_data(p_data["data"])
			if "damage" in p_data:
				print("server damage!")
				p_obj.data["health"] -= p_data["damage"]
			else:
				print("Update without damage!")
			continue
		if p_obj == null:
			print("Making player: ", player)
			p_obj = person.instance()
			p_obj.name = player
			$Map/Players.add_child(p_obj)
		var mom = p_data.get("momentum", [0, 0, 0])
		var pos = p_data.get("position", [0, 0, 0])
		var rot = p_data.get("rotation", [0, 0, 0])
		var t = OS.get_unix_time()
		p_obj.set_remote_values(p_data, new_timestamp)
		
		if "model" in p_data:
			p_obj.set_model(p_data["model"])
	
	for obj in data.get("objects", {}):
		var obj_name = obj.replace("@", "")
		var obj_data = data["objects"][obj]
		if obj_data.get("last_update_from", "") == username:
			continue
		var obj_obj = $Map/Objects.get_node(obj_name)
		if obj_obj == null and not obj_data.get("kill", false):
			obj_obj = make_obj(obj_data["type"], obj_name, true)
			if obj_obj == null:
				print("Unable to create online obj")
				continue
		if obj_obj:
			obj_obj.get_update(obj_data, obj_data.get("timestamp", -1))
	for obj in $Map/Objects.get_children():
		if not (obj.name in data.get("objects", {})) and obj.created_online:
			print("Deleting: ", obj.get_name())
			obj.queue_free()
		else:
			#print("Maybe delete?: ", obj.get_name())
			pass

func get_player():
	return $Map/Players.get_node(username)

var obj_offset = 1
func make_obj(type, n="", co=false):
	obj_offset += 1
	if n == "":
		n = username + "_thing_" + str(1+obj_offset)
	if not (type in object_types):
		return null
	var obj_name = n.replace("@", "")
	var obj_obj = $Map/Objects.get_node(obj_name)
	if obj_obj != null:
		return obj_obj
	obj_obj = object_types[type].instance()
	var otrans = obj_obj.get_global_transform()
	obj_obj.set_name(str(obj_name))
	$Map/Objects.add_child(obj_obj)
	obj_obj.set_global_transform(otrans)
	obj_obj.set_name(str(obj_name))
	obj_obj.created_online = co
	print("object "+n+" given name: "+obj_obj.name)
	if obj_obj.get_name() != obj_name:
		print("Deleting object, unable to assign correct name")
		obj_obj.get_parent().remove_child(obj_obj)
		obj_obj.queue_free()
		return null
	return obj_obj




