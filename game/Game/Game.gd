extends Spatial


# arenas
var menu_background_pck = preload("res://Game/Areas/Backgrounds/MenuBackground.tscn")
var arenas = {
	"fp_debugarea": {
		"scene": preload("res://Game/Areas/Debug/DebugArea.tscn"),
		"name": "Debug Area",
		"description": "The debug area",
		"gamemode": "fp"
	},
	"fp_worstmap": {
		"scene": preload("res://Game/Areas/Arena/dg_worstmap/dg_worstmap.tscn"),
		"name": "Worst map",
		"description": "Simple combat testing map.",
		"gamemode": "fp"
	},
	"fp_officemap": {
		"scene": preload("res://Game/Areas/Blocks/Office/dg_officemap.tscn"),
		"name": "dg_officemap",
		"description": "cs_office, am I right?",
		"gamemode": "fp"
	},
	"fp_monkeylabs": {
		"scene": preload("res://Game/Areas/Blocks/Monkeylabs/dg_monkeylabs.tscn"),
		"name": "dg_monkeylabs",
		"description": "The real Monkey Labs...",
		"gamemode": "fp"
	},
	"dg_fd": {
		"scene": preload("res://Game/Areas/Arena/dg_fd/dg_fd.tscn"),
		"name": "dg_fd",
		"description": "A 'Duck Game' final destination!\nWho knows where this will lead???",
		"gamemode": "dg"
	},
	"fp_hub": {
		"scene": preload("res://Game/Areas/Hub/Hubmap.tscn"),
		"name": "fp_hub",
		"description": "hub world",
		"gamemode": "fp"
	},
	"fp_maze1": {
		"scene": preload("res://Game/Areas/Arena/maze_maze/maze1.tscn"),
		"name": "fp_maze1",
		"description": "maze1",
		"gamemode": "fp"
	},
	"fp_maze2": {
		"scene": preload("res://Game/Areas/Arena/maze_maze/maze1.tscn"),
		"name": "fp_maze2",
		"description": "maze2, fool",
		"gamemode": "fp"
	},
}
var menu_types = {
	"fp": preload("res://Game/Menus/GameModes/fp/FreePlayMenu.tscn"),
	"dg": preload("res://Game/Menus/GameModes/dg/DuckGameMenu.tscn"),
}
var object_types = {
	"BasicBullet": preload("res://Game/Objects/GameObjects/Bullets/BasicBullet/BasicBullet.tscn"),
	"barrell": preload("res://Game/Objects/GameObjects/Barrell/Barrell.tscn"),
	"bullet": preload("res://Game/Objects/GameObjects/Bullets/Bullet.tscn"),
	"BulletBrain": preload("res://Game/Objects/GameObjects/Bullets/BulletBrain/BulletBrain.tscn"),
	"gun": preload("res://Game/Objects/GameObjects/Guns/Gun.tscn"),
	"Gun_HandGun": preload("res://Game/Objects/GameObjects/Guns/HandGun/Gun_HandGun.tscn"),
	"Gun_AK47": preload("res://Game/Objects/GameObjects/Guns/AK47/Gun_AK47.tscn"),
	"Gun_BrainGun": preload("res://Game/Objects/GameObjects/Guns/BrainGun/Gun_BrainGun.tscn"),
	"Gun_BK47": preload("res://Game/Objects/GameObjects/Guns/BK47/Gun_BK47.tscn"),
	"GunSpawner": preload("res://Game/Objects/GameObjects/GunSpawner/GunSpawner.tscn"),
	"HeldObject": preload("res://Game/Objects/GameObjects/Guns/HeldObject.tscn"),
	"HeldObject_HandGun": preload("res://Game/Objects/GameObjects/Guns/HandGun/HeldObject_HandGun.tscn"),
	"HeldObject_AK47": preload("res://Game/Objects/GameObjects/Guns/AK47/HeldObject_AK47.tscn"),
	"HeldObject_BrainGun": preload("res://Game/Objects/GameObjects/Guns/BrainGun/HeldObject_BrainGun.tscn"),
	"HeldObject_BK47": preload("res://Game/Objects/GameObjects/Guns/BK47/HeldObject_BK47.tscn"),
}
var person = preload("res://Game/Characters/Players/Person.tscn")

onready var GameViewport = $"GameViewport/GameViewport"
onready var MenuViewport = $"MenuViewport/MenuViewport"

onready var Web = $"MenuViewport/MenuViewport/Web"
onready var UI = $"MenuViewport/MenuViewport/UI"
onready var HUD = $"MenuViewport/MenuViewport/HUD/Hud"
onready var ModeMenu = $"MenuViewport/MenuViewport/UI/ModeMenu"
onready var PauseMenu = $"MenuViewport/MenuViewport/UI/PauseMenu"
onready var NotificationSystem = $"MenuViewport/NotificationViewport/NotificationSystem"

onready var Arena = $"GameViewport/GameViewport/Map/Arena"
onready var Objects = $"GameViewport/GameViewport/Map/Objects"
onready var Players = $"GameViewport/GameViewport/Map/Players"


# Game vars
var username = "DEFAULT_USER"
var base_lobby = "DEFAULT"
var lobby = base_lobby
var singleplayer = false
var team = 1
var settings = {
	"gamemode": "fp",
	"time": 0,
	"serv_version": 0,
	"random_seed": 0
}
var serv_version_just_changed = false
var just_logged_in = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load menu
	var menu_background = menu_background_pck.instance()
	Arena.add_child(menu_background)
	menu_background.name = "ARENA"
	
	# Set min window size
	OS.min_window_size = Vector2(640, 360)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause_menu()
	if Input.is_action_just_pressed("ui_clear"):
		return
		show_hud = not show_hud
		if show_hud and menu_up and not UI.visible:
			UI.visible = true
		if not show_hud and menu_up and UI.visible:
			UI.visible = false

var menu_up = true
var show_hud = true
func toggle_pause_menu(show=-1):
	if int(show) == -1:
		show = menu_up
	else:
		assert(show in [true, false], "Improper toggle val: "+str(show))
		show = not show
	if show:
		UI.visible = false
		HUD.visible = true and show_hud
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		menu_up = false
	else:
		UI.visible = true and show_hud
		HUD.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		menu_up = true

var show_mode_menu = false
func toggle_mode_menu(show=true):
	ModeMenu.visible = show
	PauseMenu.visible = not show
	if not ModeMenu.has_node(settings["gamemode"]):
		assert(
			settings["gamemode"] in menu_types, 
			"ERROR! Invalid Gamemode: "+str(settings["gamemode"])
		)
		for child in ModeMenu.get_children():
			child.queue_free()
		var new_menu = menu_types[settings["gamemode"]].instance()
		ModeMenu.add_child(new_menu)
	else:
		ModeMenu.get_node(settings["gamemode"]).refresh()

var cur_arena = ""
func load_arena(arena_name):
	assert(arena_name in arenas, "ERROR! Invalid arena: " + str(arena_name))
	print("Setting arena to ", arena_name)
	cur_arena = arena_name
	if Arena.has_node("ARENA"):
		var old_arena = Arena.get_node("ARENA")
		old_arena.name = "OLD_ARENA"
		old_arena.queue_free()
	var new_arena = arenas[arena_name]["scene"].instance()
	new_arena.name = "ARENA"
	Arena.add_child(new_arena)
	settings["gamemode"] = arenas[arena_name]["gamemode"]
	Events.alert("Welcome to " + arenas[arena_name]["name"], 4)

func load_player():
	var new_player = person.instance()
	Players.add_child(new_player)
	new_player.name = username

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
			var p_obj = Players.get_node(player)
			if "damage" in p_data:
				print("server damage!")
				p_obj.data["health"] -= p_data["damage"]
			continue
		var p_obj = null
		if not Players.has_node(player):
			p_obj = person.instance()
			p_obj.name = player
			Players.add_child(p_obj)
		else:
			p_obj = Players.get_node(player)
		var mom = p_data.get("momentum", [0, 0, 0])
		var pos = p_data.get("position", [0, 0, 0])
		var rot = p_data.get("rotation", [0, 0, 0])
		var t = OS.get_unix_time()
		p_obj.set_remote_values(p_data, OS.get_ticks_msec())
		
		if "model" in p_data:
			p_obj.set_model(p_data["model"])
	for obj in Players.get_children():
		if not (obj.name in data.get("updates", {}).get("players", {})) and obj.get_name() != username:
			obj.queue_free()
	
	for obj in data.get("objects", {}):
		var obj_name = obj.replace("@", "")
		var obj_data = data["objects"][obj]
		if obj_data.get("last_update_from", "") == username:
			continue
		if not Objects.has_node(obj_name) and not obj_data.get("kill", false):
			var obj_obj = make_obj(obj_data["type"], obj_name, true)
			if obj_obj == null:
				print("Unable to create online obj")
				continue
		var obj_obj = Objects.get_node(obj_name)
		obj_obj.get_update(obj_data, obj_data.get("timestamp", -1))
	for obj in Objects.get_children():
		if not (obj.name in data.get("objects", {})) and obj.created_online:
			obj.queue_free()
	
	# Change map
	var new_map = data.get("settings", {}).get("map", cur_arena)
	if new_map != cur_arena:
		clear_gameplay(true)
		load_arena(new_map)
		toggle_mode_menu(true)
		toggle_pause_menu(true)
	if settings["serv_version"] != data.get("settings", {}).get("serv_version", settings["serv_version"]):
		serv_version_just_changed = true
		print("Update serv version!")
		settings["serv_version"] = data.get("settings", {}).get("serv_version", settings["serv_version"])
	else:
		serv_version_just_changed = false
	
	just_logged_in = false

var obj_offset = 1
func make_obj(type, n="", co=false):
	obj_offset += 1
	if n == "":
		n = cur_arena + "_" + username + "_thing_" + str(1+obj_offset)
	if not (type in object_types):
		return null
	var obj_name = n.replace("@", "")
	if Objects.has_node(obj_name):
		return Objects.get_node(obj_name)
	var obj_obj = object_types[type].instance()
	var otrans = Transform()
	otrans.origin = Vector3(-1000, -1000, -1000)
	obj_obj.set_name(str(obj_name))
	Objects.add_child(obj_obj)
	obj_obj.set_global_transform(otrans)
	obj_obj.set_name(str(obj_name))
	obj_obj.created_online = co
	if obj_obj.get_name() != obj_name:
		print(
			"Deleting object ("+obj_obj.get_name()+
			"), unable to assign correct name '"+obj_name+"'"
		)
		obj_obj.get_parent().remove_child(obj_obj)
		obj_obj.queue_free()
		return null
	return obj_obj

func get_current_player():
	if Players.has_node(username):
		return Players.get_node(username)
	return null

func get_player(p):
	if Players.has_node(p):
		return Players.get_node(p)
	return null

func clear_gameplay(kill=false):
	var del_num = 0
	for child in Arena.get_children():
		child.set_name("to_delete_"+str(del_num))
		child.queue_free()
		del_num += 1
	for child in Objects.get_children():
		child.set_name("to_delete_"+str(del_num))
		if kill:
			child.kill = true
			child.send_update()
		if singleplayer:
			child.queue_free()
		del_num += 1
	for child in Players.get_children():
		child.set_name("to_delete_"+str(del_num))
		child.queue_free()
		del_num += 1

var last_rel = Vector2()
func _input(event):
	if menu_up:
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		last_rel = event.relative

func get_mouse_movement():
	var send = last_rel
	last_rel = Vector2()
	return send

func change_lobby(bl, mod):
	base_lobby = bl
	lobby = bl
	if mod != "":
		lobby += "_" + mod
	Web.request(
		"change_lobby",
		{
			"username": username,
			"new_lobby": lobby
		}
	)
	#clear_gameplay()
