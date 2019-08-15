extends KinematicBody2D

var direct_vector = Vector2(0, 0)
export var movement_speed = 10

func _ready():
	pass

func _physics_process(delta):
	if Input.is_key_pressed(KEY_LEFT):
		direct_vector.x -= 1
	elif Input.is_key_pressed(KEY_RIGHT):
		direct_vector.x += 1
	if Input.is_key_pressed(KEY_UP):
		direct_vector.y -= 1
	elif Input.is_key_pressed(KEY_DOWN):
		direct_vector.y += 1
	direct_vector = movement_speed * direct_vector.normalized()
	move_and_slide(direct_vector)
	pass