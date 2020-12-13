extends Control


var new_table_entry = preload("res://Game/Menus/GameModes/dg/TableEntry.tscn")
onready var EntryContainer = $"VBoxContainer/EntryContainer"

var entries = {
	"harry": 50,
	"george": 69,
	"dominic": 420,
	"ducky mcduckface": 26,
	"donald": 232,
	"biden": 306
}

func _ready():
	refresh()

func _process(delta):
	pass


func refresh():
	for child in EntryContainer.get_children():
		child.queue_free()
	var users = entries.keys()
	users.sort_custom(self, "dict_sorter")
	for user in users:
		var new_entry = new_table_entry.instance()
		new_entry.set_name(user)
		new_entry.set_score(entries[user])
		EntryContainer.add_child(new_entry)

func add_entry(user, score):
	entries[user] = score
	refresh()

func dict_sorter(a, b):
	return entries[a] > entries[b]

func clear():
	entries = {}
	refresh()




