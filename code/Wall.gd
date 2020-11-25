extends Node2D

func get_size():
	var width = $UpBody/Up.region_rect.size.x
	var height = $UpBody/Up.region_rect.size.y
	if  width > height :
		return width * scale.x
	else:
		return height * scale.y

func is_left():
	return $LeftBody.visible

func is_top():
	return $UpBody.visible

func setup(up, left):
	$LeftBody.visible = false
	$LeftBody/LeftCollisionShape.disabled = true
	$UpBody.visible = false
	$UpBody/UpCollisionShape.disabled = true
	if left:
		$LeftBody.visible = true
		$LeftBody/LeftCollisionShape.disabled = false
	if up:
		$UpBody.visible = true
		$UpBody/UpCollisionShape.disabled = false

func make_corner():
	$Corner.visible = true
