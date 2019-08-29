extends Node2D

export (PackedScene) var Maze

func _on_Configuration_configuration_done():
	$Configuration.visible = false
	var maze = Maze.instance()
	maze.set_dimension($Configuration.get_dim())
	maze.set_algorythm($Configuration.get_algorythm())
	add_child(maze)
	maze.connect("on_game_finished", self, "on_finish")
	maze.start_generation()

func on_finish():
	print("Finish")
	var maze = get_node("Maze")
	if maze != null:
		maze.disconnect("on_game_finished", self, "on_finish")
		maze.queue_free()
		remove_child(maze)
		$Configuration.visible = true