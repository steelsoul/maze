extends KinematicBody2D

export var movement_speed = 20

func _ready():
	pass

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
	if acc_vec.length() != 0:
		direct_vector = Vector2(acc_vec.x, acc_vec.y)
	return direct_vector

func _physics_process(delta):
	var direct_vector = Vector2()
	direct_vector = set_direction_from_keyboard_input(direct_vector)
	direct_vector = set_direction_from_gravity_sensor(direct_vector)
	direct_vector = movement_speed * direct_vector.normalized()
	move_and_slide(direct_vector)