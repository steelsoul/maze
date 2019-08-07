extends Node2D

func get_size():
	return max($Up.region_rect.size.x, $Up.region_rect.size.y)

func setup(up, left):
	if left:
		$Left.visible = true
	if up:
		$Up.visible = true
