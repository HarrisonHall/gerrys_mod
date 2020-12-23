extends Node


onready var Root = get_tree().get_current_scene()
onready var GameViewport = Root.get_node("GameViewport/GameViewport")
onready var MenuViewport = Root.get_node("MenuViewport/MenuViewport")

onready var Web = Root.get_node("MenuViewport/MenuViewport/Web")
onready var UI = Root.get_node("MenuViewport/MenuViewport/UI")
onready var HUD = Root.get_node("MenuViewport/MenuViewport/HUD/Hud")
onready var ModeMenu = Root.get_node("MenuViewport/MenuViewport/UI/ModeMenu")
onready var PauseMenu = Root.get_node("MenuViewport/MenuViewport/UI/PauseMenu")
onready var NotificationSystem = Root.get_node("MenuViewport/NotificationViewport/NotificationSystem")

onready var Arena = Root.get_node("GameViewport/GameViewport/Map/Arena")
onready var Objects = Root.get_node("GameViewport/GameViewport/Map/Objects")
onready var Players = Root.get_node("GameViewport/GameViewport/Map/Players")


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
var cur_arena = ""


func _ready():
	# Set min window size
	OS.min_window_size = Vector2(640, 360)

var last_rel = Vector2()
func _input(event):
	if menu_up:
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		last_rel = event.relative

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause_menu()

# Change lobby 
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

# Clean up all game objects
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

func get_arena():
	if Arena.has_node("ARENA"):
		return Arena.get_node("ARENA")
	else:
		print("Arena children: ", Arena.get_children())
	return null

# Get node of current player
func get_current_player():
	if Players.has_node(username):
		return Players.get_node(username)
	return null

func get_mouse_movement():
	var send = last_rel
	last_rel = Vector2()
	return send

# Get player by name
func get_player(p):
	if Players.has_node(p):
		return Players.get_node(p)
	return null

func get_player_count():
	return len(Players.get_children())

var show_mode_menu = false
func toggle_mode_menu(show=true):
	# Toggle the mode menu
	ModeMenu.visible = show
	PauseMenu.visible = not show
	if not ModeMenu.has_node(settings["gamemode"]):
		assert(
			settings["gamemode"] in Resources.menu_types, 
			"ERROR! Invalid Gamemode: "+str(settings["gamemode"])
		)
		for child in ModeMenu.get_children():
			child.queue_free()
		var new_menu = Resources.menu_types[settings["gamemode"]].instance()
		ModeMenu.add_child(new_menu)
	else:
		ModeMenu.get_node(settings["gamemode"]).refresh()

var menu_up = true
var show_hud = true
func toggle_pause_menu(show=-1):
	# Toggle pause menu
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

var last_timestamp = -1
# Update game from online packet
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
			p_obj = Resources.person.instance()
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
			var obj_obj = Resources.make_obj(obj_data["type"], obj_name, true)
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
		Resources.load_arena(new_map)
		toggle_mode_menu(true)
		toggle_pause_menu(true)
	if settings["serv_version"] != data.get("settings", {}).get("serv_version", settings["serv_version"]):
		serv_version_just_changed = true
		print("Update serv version!")
		settings["serv_version"] = data.get("settings", {}).get("serv_version", settings["serv_version"])
	else:
		serv_version_just_changed = false
	
	just_logged_in = false
