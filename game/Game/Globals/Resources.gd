extends Node


var menu_background_pck = preload("res://Game/Arena/Backgrounds/MenuBackground.tscn")
var arenas = {
	"fp_debugarea": {
		"scene": preload("res://Game/Arena/Arenas/DebugArea/DebugArea.tscn"),
		"name": "Debug Area",
		"description": "The debug area",
		"gamemode": "fp"
	},
	"fp_officemap": {
		"scene": preload("res://Game/Arena/Arenas/Office/dg_officemap.tscn"),
		"name": "dg_officemap",
		"description": "cs_office, am I right?",
		"gamemode": "fp"
	},
	"fp_monkeylabs": {
		"scene": preload("res://Game/Arena/Arenas/MonkeyLabs/dg_monkeylabs.tscn"),
		"name": "dg_monkeylabs",
		"description": "The real Monkey Labs...",
		"gamemode": "fp"
	},
	"dg_fd": {
		"scene": preload("res://Game/Arena/Arenas/FinalDestination/dg_fd.tscn"),
		"name": "dg_fd",
		"description": "A 'Duck Game' final destination!\nWho knows where this will lead???",
		"gamemode": "dg"
	},
	"fp_hub": {
		"scene": preload("res://Game/Arena/Arenas/Hub/Hubmap.tscn"),
		"name": "fp_hub",
		"description": "hub world",
		"gamemode": "fp"
	},
	"fp_maze1": {
		"scene": preload("res://Game/Arena/Arenas/Maze1/maze1.tscn"),
		"name": "fp_maze1",
		"description": "maze1",
		"gamemode": "fp"
	},
	"fp_maze2": {
		"scene": preload("res://Game/Arena/Arenas/Maze1/maze1.tscn"),
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
	"Barrell": preload("res://Game/Objects/GameObjects/Barrell/Barrell.tscn"),
	"Bullet": preload("res://Game/Objects/GameObjects/Bullets/Bullet.tscn"),
	"BulletBrain": preload("res://Game/Objects/GameObjects/Bullets/BulletBrain/BulletBrain.tscn"),
	"Casing": preload("res://Game/Objects/GameObjects/Guns/BK47/Casing/Casing.tscn"),
	"Flash": preload("res://Game/Objects/Weapons/muzzleflashtest.tscn"),
	"Gun": preload("res://Game/Objects/GameObjects/Guns/Gun.tscn"),
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
var person = preload("res://Game/Players/Characters/Players/Person.tscn")


func load_arena(arena_name):
	assert(arena_name in arenas, "ERROR! Invalid arena: " + str(arena_name))
	print("Setting arena to ", arena_name)
	Game.cur_arena = arena_name
	if Game.Arena.has_node("ARENA"):
		var old_arena = Game.Arena.get_node("ARENA")
		old_arena.name = "OLD_ARENA"
		old_arena.queue_free()
	var new_arena = arenas[arena_name]["scene"].instance()
	new_arena.name = "ARENA"
	Game.Arena.add_child(new_arena)
	Game.settings["gamemode"] = arenas[arena_name]["gamemode"]
	Events.alert("Welcome to " + arenas[arena_name]["name"], 4)

func load_player():
	var new_player = person.instance()
	Game.Players.add_child(new_player)
	new_player.name = Game.username

var obj_offset = 1
func make_obj(type, n="", co=false):
	obj_offset += 1
	if n == "":
		n = Game.cur_arena + "_" + Game.username + "_thing_" + str(1+obj_offset)
	if not (type in object_types):
		return null
	var obj_name = n.replace("@", "")
	if Game.Objects.has_node(obj_name):
		return Game.Objects.get_node(obj_name)
	var obj_obj = object_types[type].instance()
	var otrans = Transform()
	otrans.origin = Vector3(-1000, -1000, -1000)
	obj_obj.set_name(str(obj_name))
	Game.Objects.add_child(obj_obj)
	obj_obj.set_global_transform(otrans)
	obj_obj.set_name(str(obj_name))
	print("Made obj: ", type)
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
