extends Camera2D

# ===== Exports
# ============================================================================ #
## Default zoom
@export
var zoom_default: float = 2.0
## Max zoom out
@export
var min_zoom: float = 0.2
## Max zoom in
@export
var max_zoom: float = 20
## Controls how much we increase or decrease the `_zoom_level` on every turn of the scroll wheel.
@export
var zoom_factor: float = 0.2
## Duration of the zoom's tween animation.
@export
var zoom_duration: float = 0.2


var zoomInput: float = 0;
var zoomScroll: bool = false;

# ===== Class Parameters
# ============================================================================ #

## The camera's target zoom level.
## @ref: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#properties-setters-and-getters
var _zoom_level: float = zoom_default:
	set(value):
		# We limit the value between `min_zoom` and `max_zoom`
		_zoom_level = clamp(value, min_zoom, max_zoom)
		# print(value,' | ', _zoom_level)
		# _set_zoom(_zoom_level)
		_set_zoom_smooth(_zoom_level, zoom_duration)

# ===== Lifecycle hooks
# ============================================================================ #

# Called when the node enters the scene tree for the first time.
func _ready():
	zoom = Vector2(zoom_default, zoom_default);
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("window_fullscreen"):
		swap_fullscreen_mode()

	# Continuous zoom is faster than incramental, adjust for that
	var deviceZoomFactor = zoom_factor;
	if(!zoomScroll): deviceZoomFactor /= 4;

	var zoomAmount = 1 + deviceZoomFactor * abs(zoomInput)
	if(zoomInput > 0):
		_zoom_level *= zoomAmount
	if(zoomInput < 0):
		_zoom_level /= zoomAmount

	# Incramental zoom with a scroll wheel vs continuous when holding button
	if(zoomScroll):
		zoomInput = 0;
		zoomScroll = false;

	#print("Zoom ", _zoom_level)

	#var zoomInput := Vector2(Input.get_action_strength("zoom_in"), Input.get_action_strength("zoom_out"));
	#print("zoomInput", zoomInput)

	#if Input.is_action_just_released("zoom_in"):
		#print("zoom_in", Input.get_action_strength("zoom_in"))
		#_zoom_level *= 1 + zoom_factor * Input.get_action_strength("zoom_in")
	#if Input.is_action_just_released("zoom_out"):
		#print("zoom_out", Input.get_action_strength("zoom_out"))
		#_zoom_level /= 1 + zoom_factor * Input.get_action_strength("zoom_out")
	if Input.is_action_pressed("zoom_reset"):
		_zoom_level = zoom_default

func _unhandled_input(event: InputEvent):
	if(event is InputEventMouseButton):
		if(zoomInput != 0 ): return;
		else: zoomScroll = true;
	zoomInput = Input.get_action_strength("zoom_in") - Input.get_action_strength("zoom_out");


	#zoom_with_keyboard(event);
	#zoom_with_joystic(event);

func zoom_with_keyboard(event):
	# print('Zoom Level: ', _zoom_level,' | ', zoom)
	if event.is_action_pressed("zoom_in"):
		print("zoom_in", event.get_action_strength("zoom_in"))
		_zoom_level *= zoom_factor * event.get_action_strength("zoom_in")
	if event.is_action_pressed("zoom_out"):
		print("zoom_out", event.get_action_strength("zoom_out"))
		_zoom_level /= zoom_factor * event.get_action_strength("zoom_out")
	if event.is_action_pressed("zoom_reset"):
		_zoom_level = zoom_default


func zoom_with_joystic(event):
	# print('Zoom Level: ', _zoom_level,' | ', zoom)
	if event.is_action("zoom_in"):
		print("zoom_in", event.get_action_strength("zoom_in"))
		_zoom_level /= 1 + zoom_factor * event.get_action_strength("zoom_in") / 100
	if event.is_action("zoom_out"):
		print("zoom_out", event.get_action_strength("zoom_out"))
		_zoom_level *= 1 + zoom_factor * event.get_action_strength("zoom_out") / 100
	if event.is_action("zoom_reset"):
		_zoom_level = zoom_default

# ===== Class Functions
# ============================================================================ #

## Sets camera zoom directly with no animation
func _set_zoom(zoom_level: float) -> void:
	zoom = Vector2(zoom_level, zoom_level)

## Uses Tween class to smothly animate zoom transition
func _set_zoom_smooth(zoom_level: float, animation_duration: float) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	# Easing out means we start fast and slow down as we reach the target value.
	tween.set_ease(Tween.EASE_OUT)

	# Then, we ask the tween node to animate the camera's `zoom` property from its current value to the target zoom level.
	tween.tween_property(self, "zoom", Vector2(zoom_level, zoom_level), animation_duration)
	tween.play()

func swap_fullscreen_mode():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
