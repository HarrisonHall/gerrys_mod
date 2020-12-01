extends Spatial


var model = null
var current_model_name = ""
var held_object = true
var last_animation = ""

var models = {
	"seagul": preload("res://Game/Characters/Players/models/seagal/v2/seagullv2test1.tscn"),
	"seagal": preload("res://Game/Characters/Players/models/seagal/v2/seagullv2test1.tscn"),
	"bokatan": preload("res://Game/Characters/Players/models/bokatan/v2/bittywithhelmetv2test1.tscn"),
	"gdchan": preload("res://Game/Characters/Players/models/gdchan/v2/gofuckv2test1.tscn"),
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
	
	model = models[new_model].instance()
	add_child(model)
	current_model_name = new_model
	return true

func make_invisible():
	if get_children()[0].get_node("bones/Skeleton") != null:
		print("making invisible")
		get_children()[0].get_node("bones/Skeleton").get_children()[0].layers = 2

func make_visible():
	if get_children()[0].get_node("bones/Skeleton") != null:
		print("visible")
		get_children()[0].get_node("bones/Skeleton").get_children()[0].layers = 1

