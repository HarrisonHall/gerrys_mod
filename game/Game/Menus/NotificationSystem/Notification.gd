extends Control


var title = ""
var message = ""
var time = 2

enum State {GROWING, RESTING, SHRINKING}
var state = State.GROWING
var grow_time = .5
var started_shrinking = false

var time_alive = 0

func _init():
	visible = true
	rect_scale = Vector2(1, 0)
	print(rect_scale, rect_size)
	modulate = Color(1, 1, 1, 0)
	rect_min_size = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	$SizeTween.interpolate_property(
		self, "rect_scale", Vector2(1, 0), Vector2(1, 1), grow_time,
		$SizeTween.TRANS_LINEAR, $SizeTween.EASE_OUT_IN
	)
	$SizeTween.interpolate_property(
		self, "modulate", modulate, Color(1, 1, 1, 1), grow_time,
		$SizeTween.TRANS_LINEAR, $SizeTween.EASE_OUT_IN
	)
	$SizeTween.interpolate_property(
		self, "rect_min_size", Vector2(0, 0), Vector2(0, 100), grow_time,
		$SizeTween.TRANS_LINEAR, $SizeTween.EASE_OUT_IN
	)
	$SizeTween.start()

func _process(delta):
	time_alive += delta
	#visible = true
#	if $SizeTween.is_active() and not visible and time_alive > .05:
#		visible = true
#	else:
#		print($SizeTween.get_runtime())
	print(rect_scale)
	if state == State.GROWING and not $SizeTween.is_active():
		state = State.RESTING
	if state == State.RESTING:
		time -= delta
		if time <= 0:
			state = State.SHRINKING
	if state == State.SHRINKING and not $SizeTween.is_active():
		if not started_shrinking:
			started_shrinking = true
			$SizeTween.interpolate_property(
				self, "rect_scale", Vector2(1, 1), Vector2(1, 0), grow_time,
				$SizeTween.TRANS_LINEAR, $SizeTween.EASE_OUT_IN
			)
			$SizeTween.interpolate_property(
				self, "modulate", modulate, Color(1, 1, 1, 0), grow_time,
				$SizeTween.TRANS_LINEAR, $SizeTween.EASE_OUT_IN
			)
			$SizeTween.interpolate_property(
				self, "rect_min_size", Vector2(0, 100), Vector2(0, 0), grow_time,
				$SizeTween.TRANS_LINEAR, $SizeTween.EASE_OUT_IN
			)
			$SizeTween.start()
		else:
			queue_free()

func set_title(t):
	title = t

func set_message(m):
	message = m

func set_time(t):
	time = t

func update_info():
	$VBoxContainer/Label.text = title
	$VBoxContainer/RichTextLabel2.text = message
