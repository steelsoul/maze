extends Node2D

func get_size():
	return max($UpBody/Up.region_rect.size.x, $UpBody/Up.region_rect.size.y)

func is_left():
	return $LeftBody.visible

func is_top():
	return $UpBody.visible

func setup(up, left):
	if left:
		$LeftBody.visible = true
		$LeftBody/LeftCollisionShape.disabled = false
	if up:
		$UpBody.visible = true
		$UpBody/UpCollisionShape.disabled = false

func make_corner():
	$Corner.visible = true
