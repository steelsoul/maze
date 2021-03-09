extends Area2D

enum Type {Solution, Block}
var type_
var map_

func _init(type, mazemap: TileMap):
	type_ = type
	map_ = mazemap
	setup_sprite()

func setup_sprite():
	match type_:
		Type.Solution: $Sprite.texture = load("res://arts/s.png")
		Type.Block:	$Sprite.texture = load("res://arts/X.png")

func _on_body_shape_entered(body_id, body, body_shape, area_shape):
	var location = map_.world_to_map(position)
	match type_:
		Type.Solution: body.pickup_key(location)
		Type.Block: 
			# KS --require key-> BODY
			# KS <-found key--   BODY
			# if KEY KS.disappear 
			var key_found = body.require_key(location)
			if key_found: disappear()

func disappear():
	self.queue_free()
