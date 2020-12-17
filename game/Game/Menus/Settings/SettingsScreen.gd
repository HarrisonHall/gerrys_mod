extends Control


onready var Game = get_tree().get_current_scene()

var set_graphics = false
var shader_a = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_ScreenSize_item_selected(2)
	
func _process(delta):
	if not set_graphics:
		_on_VisualOptions_item_selected(1)
		set_graphics = true
		
	if Game.GameViewport.get_parent().material.shader:
		if Input.is_action_pressed("ui_bracketleft"):
			shader_a -= 0.15
			Game.GameViewport.get_parent().material.set_shader_param("a", shader_a)
		elif Input.is_action_pressed("ui_bracketright"):
			shader_a += 0.15
			Game.GameViewport.get_parent().material.set_shader_param("a", shader_a)
		elif Input.is_action_just_pressed("ui_backslash"):
			shader_a = 0
			Game.GameViewport.get_parent().material.set_shader_param("a", shader_a)
			
		if Game.GameViewport.get_parent().material.shader == randomrandom_shader:
			Game.GameViewport.get_parent().material.set_shader_param("seed", randf())

func _on_MSSlider_value_changed(value):
	var player = Game.get_current_player()
	if player != null:
		player.CAM_SENSITIVITY = value


var server_choices = {
	0: "ws://gerrys-mod-demo.herokuapp.com/ping",
	1: "ws://127.0.0.1:8000/ping",
	2: "singleplayer"
}
func _on_serverbutton_item_selected(index):
	if index in server_choices:
		if server_choices[index] != "singleplayer":
			Game.Web.change_server(server_choices[index])
		print("Changed server url to ", Game.Web.url)
		if index == 2: # singleplayer
			Game.singleplayer = true
	else:
		print("Invalid server option: ", index)


func _on_VisualOptions_item_selected(index):
	var view = Game.GameViewport
	var new_size = Vector2()
	if index == 0:
		new_size = Vector2(640, 480)
		view.set_msaa(0)
	if index == 1:
		new_size = Vector2(960, 540)
		view.set_msaa(0)
	if index == 2:
		new_size = Vector2(1280, 720)
		view.set_msaa(2)
	if index == 3:
		new_size = Vector2(1920, 1080)
		view.set_msaa(3)
	if index == 4:
		new_size = Vector2(1920, 1080)
		view.set_msaa(4)
	print("is same?: ",get_tree().get_root() == get_viewport())
	if new_size != Vector2():
		print("Emitting change!")
		#view.set_size_override_stretch(true)
		#view.set_size_override(true, new_size)
		view.set_size(new_size)
		Events.emit_signal("viewport_changed")


func _on_ScreenSize_item_selected(index):
	var viewport = get_tree().get_root()
	if index == 0:
		OS.window_fullscreen = false
		OS.set_window_size(Vector2(1280, 720))
		#viewport.set_size_override(true, Vector2(1280, 720)) # Custom size for 2D.
		#viewport.set_size_override_stretch(true) # Enable stretch for custom size.
	if index == 1:
		OS.window_fullscreen = false
		OS.set_window_size(Vector2(1920, 1080))
		#viewport.set_size_override(true, Vector2(1920, 1080)) # Custom size for 2D.
		#viewport.set_size_override_stretch(true) # Enable stretch for custom size.
	if index == 2:
		OS.set_window_size(Vector2(1920, 1080))
		OS.window_fullscreen = true
		#OS.set_window_size(Vector2(1920, 1080))
		#viewport.set_size_override(true, Vector2(1920, 1080)) # Custom size for 2D.
		#viewport.set_size_override_stretch(true) # Enable stretch for custom size.


var cyber_shader = preload("res://Resources/Shaders/Cyber.shader")
var test_shader = preload("res://Resources/Shaders/test.shader")
var outline_shader = preload("res://Resources/Shaders/outline.shader")
var random_shader = preload("res://Resources/Shaders/random.shader")
var randomrandom_shader = preload("res://Resources/Shaders/randomrandom.shader")

func _on_OptionButton_item_selected(index):
	#var some_sprite_node.material = ShaderMaterial.new()
	#some_sprite_node.material.shader = WaterShader
	var gv = Game.GameViewport.get_parent()
	if index == 0:
		#gv.material = null
		gv.material.shader = null
	if index == 1:
		gv.material.shader = cyber_shader
	if index == 2:
		gv.material.shader = test_shader
	if index == 3:
		gv.material.shader = outline_shader
	if index == 4:
		gv.material.shader = random_shader
	if index == 5:
		gv.material.shader = randomrandom_shader







