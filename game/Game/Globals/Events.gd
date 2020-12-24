extends Node


signal viewport_changed
signal debug_on
signal debug_off

onready var NotificationSystem = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if len(nqueue) != 0:
		notify_queue()

var nqueue = []
func notify(title, message, time):
	nqueue.append([title, message, time])

func notify_queue():
	if NotificationSystem == null:
		NotificationSystem = Game.NotificationSystem
		return
	for l in nqueue:
		var title = l[0]
		var message = l[1]
		var time = l[2]
		NotificationSystem.notify(title, message, time)
	nqueue = []

func alert(message, time):
	if NotificationSystem == null:
		NotificationSystem = Game.NotificationSystem
		return
	NotificationSystem.alert(message, time)

func emit_debug():
	if Game.debug:
		emit_signal("debug_on")
	else:
		emit_signal("debug_off")





