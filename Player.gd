extends KinematicBody2D

export var min_movement_speed = 20
export var max_movement_speed = 150

var speed = 0
var is_activated = false

var input_direct = Vector2.ZERO

func _ready():
	pass

const gravity_threshold = 0.3

func activate():
	$Camera2D.current = true
	is_activated = true
	speed = 0
	input_direct = Vector2.ZERO

func deactivate():
	$Camera2D.current = false
	is_activated = false

func set_direction_from_keyboard_input(direct_vector):
	if Input.is_key_pressed(KEY_LEFT):
		direct_vector.x -= 1
	elif Input.is_key_pressed(KEY_RIGHT):
		direct_vector.x += 1
	if Input.is_key_pressed(KEY_UP):
		direct_vector.y -= 1
	elif Input.is_key_pressed(KEY_DOWN):
		direct_vector.y += 1
	return direct_vector

func set_direction_from_gravity_sensor(direct_vector):
	var acc_vec = Input.get_accelerometer() as Vector3
	if acc_vec.length() > gravity_threshold:
		direct_vector = Vector2(acc_vec.x, -acc_vec.y)
#		direct_vector.y = -1 * direct_vector.y
	return direct_vector.normalized()

func _physics_process(_delta):
	if !is_activated:
		return
		
	var direct_vector = Vector2.ZERO
	
	direct_vector = set_direction_from_keyboard_input(direct_vector)
	direct_vector = set_direction_from_gravity_sensor(direct_vector)
	
	input_direct += direct_vector
	
	speed = lerp(speed, 0, 0.1)
	
	speed = lerp(speed, max_movement_speed, direct_vector.length_squared() * 0.7)
	
	#print(speed)
	
	var p_direct_vector = speed * input_direct.normalized()
	direct_vector = move_and_slide(p_direct_vector)
	if direct_vector != p_direct_vector:
		speed = 0
		input_direct = Vector2.ZERO
