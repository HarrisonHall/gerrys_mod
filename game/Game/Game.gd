extends Spatial


# arenas
var menu_background_pck = preload("res://Game/Areas/Backgrounds/MenuBackground.tscn")
var arenas = {
	"DebugArea": {
		"scene": preload("res://Game/Areas/Debug/DebugArea.tscn"),
		"name": "Debug Area",
		"description": "The debug area",
		"mode": "Free Play"
	},
	"dg_worstmap": {
		"scene": preload("res://Game/Areas/Arena/dg_worstmap/dg_worstmap.tscn"),
		"name": "Worst map",
		"description": "Duck game arena",
		"mode": "Team Deathmatch"
	},
}
var object_types = {
	"barrell": preload("res://Game/Objects/GameObjects/Barrell/Barrell.tscn"),
	"gun": preload("res://Game/Objects/GameObjects/Guns/Gun.tscn"),
	"HeldObject": preload("res://Game/Objects/GameObjects/Guns/HeldObject.tscn"),
	"bullet": preload("res://Game/Objects/GameObjects/Bullets/Bullet.tscn"),
	"HeldObject_HandGun": preload("res://Game/Objects/GameObjects/Guns/HandGun/HeldObject_HandGun.tscn"),
	"Gun_HandGun": preload("res://Game/Objects/GameObjects/Guns/HandGun/Gun_HandGun.tscn"),
	"Gun_AK47": preload("res://Game/Objects/GameObjects/Guns/AK47/Gun_AK47.tscn"),
	"HeldObject_AK47": preload("res://Game/Objects/GameObjects/Guns/AK47/HeldObject_AK47.tscn"),
}
var person = preload("res://Game/Characters/Players/Person.tscn")

onready var Web = $Web
var menu_up = true
var show_hud = true

# Game vars
var username = "DEFAULT_USER"
var singleplayer = false
var team = 1
var settings = {
	"gamemode": "Free Play"
}


# Called when the node enters the scene tree for the first time.
func _ready():
	# load background
	
	# TODO load arena correctly
	var menu_background = menu_background_pck.instance()
	$Map/Arena.add_child(menu_background)
	menu_background.name = "ARENA"
	
	OS.min_window_size = Vector2(640, 360)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if menu_up:
			$UI.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			menu_up = false
		else:
			$UI.visible = true and show_hud
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			menu_up = true
	if Input.is_action_just_pressed("ui_clear"):
		show_hud = not show_hud
		if show_hud and menu_up and not $UI.visible:
			$UI.visible = true
		if not show_hud and menu_up and $UI.visible:
			$UI.visible = false

var cur_arena = ""
func load_arena(arena_name):
	if not arena_name in arenas:
		return
	cur_arena = arena_name
	var old_arena = $Map/Arena.get_node("ARENA")
	if old_arena != null:
		old_arena.name = "OLD_ARENA"
		old_arena.queue_free()
	var new_arena = arenas[arena_name]["scene"].instance()
	new_arena.name = "ARENA"
	$Map/Arena.add_child(new_arena)

func load_player():
	var new_player = person.instance()
	$Map/Players.add_child(new_player)
	new_player.name = username
	Web.connect("new_data", self, "update_players_s")
	#new_player.respawn(team)

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
		if player == username:  # Skip self
			#p_obj.update_data(p_data["data"])
			var p_obj = $Map/Players.get_node(player)
			if "damage" in p_data:
				print("server damage!")
				p_obj.data["health"] -= p_data["damage"]
			continue
		var p_obj = null
		if not $Map/Players.has_node(player):
			p_obj = person.instance()
			p_obj.name = player
			$Map/Players.add_child(p_obj)
		else:
			p_obj = $Map/Players.get_node(player)
		var mom = p_data.get("momentum", [0, 0, 0])
		var pos = p_data.get("position", [0, 0, 0])
		var rot = p_data.get("rotation", [0, 0, 0])
		var t = OS.get_unix_time()
		p_obj.set_remote_values(p_data, OS.get_ticks_msec())
		
		if "model" in p_data:
			p_obj.set_model(p_data["model"])
	for obj in $Map/Players.get_children():
		if not (obj.name in data.get("updates", {}).get("players", {})) and obj.get_name() != username:
			obj.queue_free()
	
	for obj in data.get("objects", {}):
		var obj_name = obj.replace("@", "")
		var obj_data = data["objects"][obj]
		if obj_data.get("last_update_from", "") == username:
			continue
		if not $Map/Objects.has_node(obj_name) and not obj_data.get("kill", false):
			var obj_obj = make_obj(obj_data["type"], obj_name, true)
			if obj_obj == null:
				print("Unable to create online obj")
				continue
		var obj_obj = $Map/Objects.get_node(obj_name)
		obj_obj.get_update(obj_data, obj_data.get("timestamp", -1))
	for obj in $Map/Objects.get_children():
		if not (obj.name in data.get("objects", {})) and obj.created_online:
			obj.queue_free()

var obj_offset = 1
func make_obj(type, n="", co=false):
	obj_offset += 1
	if n == "":
		n = username + "_thing_" + str(1+obj_offset)
	if not (type in object_types):
		return null
	var obj_name = n.replace("@", "")
	if $Map/Objects.has_node(obj_name):
		return $Map/Objects.get_node(obj_name)
	var obj_obj = object_types[type].instance()
	#var otrans = obj_obj.get_global_transform()
	var otrans = Transform()
	obj_obj.set_name(str(obj_name))
	$Map/Objects.add_child(obj_obj)
	obj_obj.set_global_transform(otrans)
	obj_obj.set_name(str(obj_name))
	obj_obj.created_online = co
	if obj_obj.get_name() != obj_name:
		print("Deleting object ("+obj_obj.get_name()+"), unable to assign correct name ("+obj_name+")")
		obj_obj.get_parent().remove_child(obj_obj)
		obj_obj.queue_free()
		return null
	return obj_obj


func get_current_player():
	if $Map/Players.has_node(username):
		return $Map/Players.get_node(username)
	return null

func clear_gameplay():
	for child in $Map/Arena.get_children():
		child.queue_free()
	for child in $Map/Objects.get_children():
		child.queue_free()
	for child in $Map/Players.get_children():
		child.queue_free()





