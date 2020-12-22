extends Control


var NewNotification = preload("res://Game/Menus/NotificationSystem/Notification.tscn")

onready var cont = $HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer
onready var alert_label = $VBoxContainer/AlertLabel

var time_to_clear = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_to_clear -= delta
	if time_to_clear <= 0:
		alert_label.text = ""

func notify(title, message, time):
	print("Got notification")
	var nn = NewNotification.instance()
	nn.set_title(title)
	nn.set_message(message)
	nn.set_time(time)
	nn.update_info()
	cont.add_child(nn)
	cont.move_child(nn, 0)

func alert(message, time):
	alert_label.text = message
	time_to_clear = time
