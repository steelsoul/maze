extends Node2D

func _on_Button_pressed():
	var text = $Panel/VBoxContainer/TextEdit.text
	var maze = read_maze(text)
	$Maze.setup_maze(maze)
	$Maze.show()
	$Panel.hide()

func read_maze(input: String):
	var start_pos = 0
	var end_pos = 0
	var maze = []
	while (end_pos != -1):
		end_pos = input.find(',', start_pos)
		if end_pos != -1:
			var substring = input.substr(start_pos, end_pos - start_pos)
			#print("S:", substring.to_int())
			maze.append(substring.to_int())
			start_pos = end_pos + 1
	if start_pos < input.length():
		var substring = input.substr(start_pos)
		#print("S:", substring.to_int())
		maze.append(substring.to_int())
	# Two first values shall be passed in Vector2
	var dim = Vector2(maze[0], maze[1])
	maze.pop_front()
	maze.pop_front()
	return [dim, maze]
# Maze to check
# 5, 5, 3, 2, 3, 3, 2, 1, 3, 0, 3, 0, 1, 2, 0, 2, 0, 3, 0, 3, 0, 2, 3, 0, 1, 1, 1
