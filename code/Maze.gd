extends Node2D

signal game_over
 
var MazeGenerator = preload("res://code/MazeGenerator.gd")
var CellHolder = preload("res://code/CellHolder.gd")

enum CellType {CLOSE, LEFT, UP, ADDITIONAL}
enum FloorCellType {FLOOR, SOLUTION, BARRICADE}

const ball_regions_to_clear = 40

func setup_maze(maze, quest = null):
	var dim = maze[0]
	var rep = maze[1]

	for y in range(dim.y):
		for x in range(dim.x):
			$Floor.set_cellv(Vector2(x,y), 1)
			match rep[MazeGenerator.get_index_from_coord(Vector2(x,y), dim)]:
				MazeGenerator.CellKind.OPEN:
					pass
				MazeGenerator.CellKind.CLOSE:
					$Map.set_cellv(Vector2(x,y), 3)
					add_occluder_to_shapes(x,y,CellType.CLOSE)
				MazeGenerator.CellKind.HAS_UP:
					$Map.set_cellv(Vector2(x,y), 0)
					add_occluder_to_shapes(x,y,CellType.UP)
				MazeGenerator.CellKind.HAS_LEFT:
					$Map.set_cellv(Vector2(x,y), 1)
					add_occluder_to_shapes(x,y,CellType.LEFT)
			if check_corner_case_condition(rep, dim, x, y):
				$Map.set_cellv(Vector2(x+1, y+1), 2)
				add_occluder_to_shapes(x+1,y+1,CellType.ADDITIONAL)
	for i in range(dim.x):
		$Map.set_cellv(Vector2(i, dim.y), 0)
		add_occluder_to_shapes(i, dim.y, CellType.UP)
	for i in range(dim.y):
		$Map.set_cellv(Vector2(dim.x, i), 1)
		add_occluder_to_shapes(dim.x, i, CellType.LEFT)
	$Map.set_cellv(Vector2(dim.x, dim.y), 2)
	
	if quest != null and quest.is_enabled():
		var obstacle_index = quest.doors_[0]
		var obstacle_position = MazeGenerator.get_coordinate_from_index(obstacle_index, dim)
		var obstacle_holder = CellHolder.new(CellHolder.Type.Block, $Floor)
		obstacle_holder.position = $Floor.map_to_world(obstacle_position)
		$Holders.add_child(obstacle_holder)
		#$Floor.set_cellv(obstacle_position, 5)
		var solution_index = quest.keys_[0]
		var key_position = MazeGenerator.get_coordinate_from_index(solution_index, dim)
		$Floor.set_cellv(key_position, 4)
	
	place_fog(dim)
	$Player.connect("moving", self, "on_player_movement")
	on_player_movement()

func check_corner_case_condition(rep, dim, x, y):
	if (x >= dim.x-1) || (y >= dim.y-1): return false
	var id2 = MazeGenerator.get_index_from_coord(Vector2(x+1,y), dim)
	if rep[id2] != MazeGenerator.CellKind.HAS_LEFT && rep[id2] != MazeGenerator.CellKind.CLOSE: return false
	var id1 = MazeGenerator.get_index_from_coord(Vector2(x,y+1), dim)
	# first shall be UP otherwords be 1X
	return rep[id1] & 2 == 2

func setup_game(player_pos: Vector2, goal_pos: Vector2, night_mode = false):
	var cell_size_2 = $Map.cell_size / 2
	var const_offset = Vector2(10, 10)
	$Player.position = ($Map.map_to_world(player_pos, false) + cell_size_2) * $Map.scale + const_offset
	$Goal.position   = ($Map.map_to_world(goal_pos, false) + cell_size_2) * $Map.scale + const_offset
#	print("Player pos: ", $Player.position)
#	print("Goal pos: ", $Goal.position)
	$Player.show()
	$Goal.show()
	$Player.activate()
	if night_mode:
		$Player.turn_light_on()
		$CanvasModulate.show()
		$ShadowCasters.show()
	else:
		$CanvasModulate.hide()
		$ShadowCasters.hide()

func place_fog(cover_dim: Vector2):
	var k = 150 / 64 + 1
	var side_adj = 0
	for x in range(0, cover_dim.x*k + 2*side_adj):
		for y in range(0, cover_dim.y*k + 2*side_adj):
			# adding fog
			$Fog.set_cellv(Vector2(x,y), 0)

func cleanup():
	for x in $ShadowCasters.get_children():
		$ShadowCasters.call_deferred("remove_child", x)
	$Player.hide()
	$Goal.hide()
	$Map.clear()
	$Player.deactivate()
	enable_input_layer(false)

func _on_Goal_reach_goal():
	emit_signal("game_over")

func add_occluder_to_shapes(x, y, cellkind):
	var cell_position = $Map.map_to_world(Vector2(x,y), false) * $Map.scale
	var light_occluder = LightOccluder2D.new()
	var poly = OccluderPolygon2D.new()
	poly.closed = true
	poly.cull_mode = OccluderPolygon2D.CULL_DISABLED
	var points_array = []
	if cellkind == CellType.CLOSE:
		points_array = [Vector2(0,0), Vector2(75,0), Vector2(75,15), Vector2(15,15),
		Vector2(15,75), Vector2(0, 75)]
	elif cellkind == CellType.UP:
		points_array = [Vector2(0,0), Vector2(75,0), Vector2(75,15), Vector2(0,15)]
	elif cellkind == CellType.LEFT:
		points_array = [Vector2(0,0), Vector2(15,0), Vector2(15,75), Vector2(0,75)]
	elif cellkind == CellType.ADDITIONAL:
		points_array = [Vector2(0,0), Vector2(15,0), Vector2(15,15), Vector2(0,15)]
	for i in range(points_array.size()):
		points_array[i] += cell_position
	poly.set_polygon(points_array)
	light_occluder.set_occluder_polygon(poly)
	#$ShadowCasters.call_deferred("add_child", light_occluder)
	$ShadowCasters.add_child(light_occluder)

func set_night_mode():
	$CanvasModulate.show()
	$ShadowCasters.show()

func enable_input_layer(enable=true):
	if enable:
		$Input/InpulPane.show()
	else:
		$Input/InpulPane.hide()

func _on_LU_button_down():
	var direction = Vector2.ZERO
	if $Input/InpulPane/NW.is_pressed():
		direction += Vector2(-1, -1)
	if $Input/InpulPane/N.is_pressed():
		direction += Vector2(0, -1)
	if $Input/InpulPane/NE.is_pressed():
		direction += Vector2(1, -1)
	if $Input/InpulPane/W.is_pressed():
		direction += Vector2(-1, 0)
	if $Input/InpulPane/E.is_pressed():
		direction += Vector2(1, 0)
	if $Input/InpulPane/SW.is_pressed():
		direction += Vector2(-1, 1)
	if $Input/InpulPane/S.is_pressed():
		direction += Vector2(0, 1)
	if $Input/InpulPane/SE.is_pressed():
		direction += Vector2(1, 1)
	if $Input/InpulPane/C.is_pressed():
		direction = Vector2.ZERO
	$Player.set_direct_direction(direction)

func on_player_movement():
	var k = ball_regions_to_clear
	for x in range(0, 6):
		for y in range(0, 6):
			var xoffset = k/2 * x - k
			var yoffset = k/2 * y - k
			var adj = $Fog.to_local($Player.position) + Vector2(xoffset, yoffset)
			var loc = $Fog.world_to_map(adj)
			$Fog.set_cellv(loc, -1)
