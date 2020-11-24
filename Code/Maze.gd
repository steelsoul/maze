extends Node2D

signal game_over
 
var MazeGenerator = preload("res://code/MazeGenerator.gd")

func setup_maze(maze):
	var dim = maze[0]
	var rep = maze[1]
	for y in range(dim.y):
		for x in range(dim.x):
			match rep[MazeGenerator.get_index_from_coord(Vector2(x,y), dim)]:
				MazeGenerator.CellKind.OPEN:
					pass
				MazeGenerator.CellKind.CLOSE:
					$Map.set_cellv(Vector2(x,y), 3)
				MazeGenerator.CellKind.HAS_UP:
					$Map.set_cellv(Vector2(x,y), 0)
				MazeGenerator.CellKind.HAS_LEFT:
					$Map.set_cellv(Vector2(x,y), 1)
			if check_corner_case_condition(rep, dim, x, y):
				$Map.set_cellv(Vector2(x+1, y+1), 2)
	for i in range(dim.x):
		$Map.set_cellv(Vector2(i, dim.y), 0)
	for i in range(dim.y):
		$Map.set_cellv(Vector2(dim.x, i), 1)
	$Map.set_cellv(Vector2(dim.x, dim.y), 2)

func check_corner_case_condition(rep, dim, x, y):
	if (x >= dim.x-1) || (y >= dim.y-1): return false
	var id1 = MazeGenerator.get_index_from_coord(Vector2(x,y+1), dim)
	var id2 = MazeGenerator.get_index_from_coord(Vector2(x+1,y), dim)
	return rep[id1] | rep[id2] == 3

func setup_game(player_pos: Vector2, goal_pos: Vector2):
	var cell_size_2 = $Map.cell_size / 2
	var const_offset = Vector2(10, 10)
	$Player.position = ($Map.map_to_world(player_pos, false) + cell_size_2) * $Map.scale + const_offset
	$Goal.position   = ($Map.map_to_world(goal_pos, false) + cell_size_2) * $Map.scale + const_offset
#	print("Player pos: ", $Player.position)
#	print("Goal pos: ", $Goal.position)
	$Player.show()
	$Goal.show()
	$Player.activate()

func cleanup():
	$Player.hide()
	$Goal.hide()
	$Map.clear()
	$Player.deactivate()

func _on_Goal_reach_goal():
	emit_signal("game_over")
