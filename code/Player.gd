extends KinematicBody2D

var keys = []
var is_activated = false
var direct_direction: Vector2

func activate():
	$Camera2D.current = true
	is_activated = true

func deactivate():
	$Camera2D.current = false
	is_activated = false
	$Light2D.hide()

func set_direction_from_keyboard_input():
	var direct_vector = Vector2.ZERO
	if Input.is_action_pressed("go_left"):
		direct_vector.x -= 1
	elif Input.is_action_pressed("go_right"):
		direct_vector.x += 1
	if Input.is_action_pressed("go_up"):
		direct_vector.y -= 1
	elif Input.is_action_pressed("go_down"):
		direct_vector.y += 1
	return direct_vector

func set_direction_from_gravity_sensor():
	var acc_vec = Input.get_accelerometer() as Vector3
	return Vector2(acc_vec.x, -acc_vec.y)

func _physics_process(_delta):
	if !is_activated:
		return
		
	var direct_vector = Vector2.ZERO
	if Input.get_gravity():
		direct_vector = set_direction_from_gravity_sensor().clamped(1.0) * 3
	else:
		direct_vector = set_direction_from_keyboard_input() * 3
		
	if direct_vector == Vector2.ZERO:
		direct_vector = direct_direction
	
	if direct_vector.length_squared() > 0.25:
		move_and_collide(direct_vector)

func set_direct_direction(direction: Vector2):
	direct_direction = direction

func turn_light_on():
	$Light2D.show()

func pickup_key(location):
	keys.append(location)


