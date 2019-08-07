extends Node2D

func get_size():
	return max($Up.region_rect.size.x, $Up.region_rect.size.y)

func is_left():
	return $Left.visible

func is_top():
	return $Up.visible

func setup(up, left):
	if left:
		$Left.visible = true
	if up:
		$Up.visible = true

func make_corner():
	$Corner.visible = true
