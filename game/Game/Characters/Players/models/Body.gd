extends Spatial


var model = null
var current_model_name = ""
var last_animation = ""

onready var Game = get_tree().get_current_scene()

var models = {
	"seagul": preload("res://Game/Characters/Players/models/seagal/v2/seagullv2.tscn"),
	"seagal": preload("res://Game/Characters/Players/models/seagal/v2/seagullv2.tscn"),
	"bokatan": preload("res://Game/Characters/Players/models/bokatan/v2/bokatan.tscn"),
	"gdchan": preload("res://Game/Characters/Players/models/gdchan/v3/gdchan.tscn"),
	"orango": preload("res://Game/Characters/Players/models/Orango/Orango.tscn"),
	"gibby": preload("res://Game/Characters/Players/models/Gibby/gibby.tscn"),
	"bobby": preload("res://Game/Characters/Players/models/Bobby/bobby.tscn"),
	"bboy": preload("res://Game/Characters/Players/models/BannaBoy/bboy1.tscn"),
	"bobo": preload("res://Game/Characters/Players/models/Bobo/bobo.tscn"),
	"bobof": preload("res://Game/Characters/Players/models/BoboF/bobof.tscn"),
	"garry": preload("res://Game/Characters/Players/models/Garry/garry.tscn"),
}

signal changed_animation

# Called when the node enters the scene tree for the first time.
func _ready():
	walk()


func _process(delta):
	pass

func walk():
	if not get_ap(): 
		return
	if not held_object:
		change_animation("walk", 0.1)
	else:
		change_animation("walkholding", 0.1)

func jump():
	if not get_ap(): 
		return
	if not held_object:
		change_animation("jumpingidle", 0.5)
	else:
		change_animation("jumpingidleholding", 0.5)

func stand():
	if not get_ap(): 
		return
	if not held_object:
		change_animation("idle", 0.1)
	else:
		change_animation("idleholding", 0.1)

func shoot():
	if not get_ap(): 
		return
	change_animation("shooting", 0.1)

func kick():
	if not get_ap(): 
		return
	change_animation("kick", 0.1)

func surf():
	if not get_ap(): 
		return
	if not held_object:
		change_animation("grindidle", 0.1)
	else:
		change_animation("grindidleholding", 0.1)

func crouchwalk():
	if not get_ap(): 
		return
	if not held_object:
		change_animation("crouchwalk", 0.1)
	else:
		change_animation("crouchwalkholding", 0.1)

func crouch():
	if not get_ap(): 
		return
	if not held_object:
		change_animation("crouchidle", 0.1)
	else:
		change_animation("crouchidleholding", 0.1)

func slide():
	if not get_ap(): 
		return
	if not held_object:
		change_animation("slideidle", 0.1)
	else:
		change_animation("slideidleholding", 0.1)

func change_animation(new, time=0.1):
	if not get_ap():
		return
	if last_animation == new:
		if get_ap().current_animation != new:
			get_ap().play(new, time)
	else:
		last_animation = new
		get_ap().play(new, time)
		emit_signal("changed_animation")

func get_ap():
	if model:
		return model.get_node("AnimationPlayer")
	return null

func set_model(new_model):
	if new_model == current_model_name:
		return false
	if not (new_model in models):
		return false
	if model != null:
		model.queue_free()
		remove_child(model)
	
	model = models[new_model].instance()
	add_child(model)
	current_model_name = new_model
	if held_object:
		if get_name() == Game.username:
			hold_object(original_gun)
		else:
			soft_hold_object(gun_name)
	return true

func make_invisible():
	if get_children()[0].get_node("Armature/Skeleton") != null:
		get_children()[0].get_node("Armature/Skeleton").get_children()[0].layers = 2

func make_visible():
	if get_children()[0].get_node("Armature/Skeleton") != null:
		get_children()[0].get_node("Armature/Skeleton").get_children()[0].layers = 1

var original_gun = null
var held_object = null
func hold_object(gun):
	if held_object:
		held_object.queue_free()
	original_gun = gun
	gun_name = gun.obj_type
	held_object = Game.object_types[gun.gun_obj].instance()
	held_object.gun_ref = gun
	var hand = get_children()[0].get_node("Armature/Skeleton/AttachHand/Hand")
	#var trans = held_object.get_global_transform()
	var trans = hand.get_global_transform()
	hand.add_child(held_object)
	#trans.origin = hand.get_global_transform().origin
	held_object.set_global_transform(trans)

var gun_name = ""
func soft_hold_object(gname):
	gun_name = gname
	var old_held = held_object
	if held_object:
		held_object.queue_free()
	print(gun_name)
	held_object = Game.object_types[gun_name].instance()
	var hand = get_children()[0].get_node("Armature/Skeleton/AttachHand/Hand")
	if old_held != null:
		if old_held in hand.get_children():
			hand.remove_child(old_held)
	#var trans = held_object.get_global_transform()
	var trans = hand.get_global_transform()
	hand.add_child(held_object)
	#trans.origin = hand.get_global_transform().origin
	held_object.set_global_transform(trans)
	print("Should be holding object ", hand, held_object, old_held)
	print(held_object == old_held)

func soft_let_go():
	if held_object:
		held_object.queue_free()
		held_object = null

func let_go(pos):
	held_object.queue_free()
	held_object = null
	original_gun.let_go(pos)

func use_held_item():
	if held_object:
		held_object.use()








