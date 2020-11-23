extends Node2D

var MazeGenerator = preload("res://code/MazeGenerator.gd")

func _ready():
#	MazeGenerator.new(Vector2(10, 10)).generate_prima()
	pass

func setup_maze(maze):
	var dim = maze[0]
	var rep = maze[1]
	for y in range(dim.y):
		var s = ""
		for x in range(dim.x):
			match rep[MazeGenerator.get_index_from_coord(Vector2(x,y), dim)]:
				MazeGenerator.CellKind.OPEN:
					s += " "
					pass
				MazeGenerator.CellKind.CLOSE:
					$Map.set_cellv(Vector2(x,y), 3)
					s += "Г"
				MazeGenerator.CellKind.HAS_UP:
					$Map.set_cellv(Vector2(x,y), 0)
					s += "-"
				MazeGenerator.CellKind.HAS_LEFT:
					$Map.set_cellv(Vector2(x,y), 1)
					s += "|"
		print(s)
