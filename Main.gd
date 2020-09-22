extends Node2D

var thread
export (PackedScene) var Maze

func _on_Configuration_configuration_done():
	$Configuration.visible = false
	var maze = Maze.instance()
	#maze.set_dimension($Configuration.get_dim())
	maze.set_algorythm($Configuration.get_algorythm())
	add_child(maze)
	maze.connect("on_game_finished", self, "on_finish")
	maze.start_generation($Configuration.get_dim())

#cleanup after maze removal
func _cleanup(maze):
	maze.stop()
	call_deferred("remove_child", maze)
	maze.disconnect("on_game_finished", self, "on_finish")
	maze.queue_free()
	$Configuration.visible = true
	thread.wait_to_finish()

func on_finish():
	#print("Finish")
	var maze = get_node("Maze")
	if maze != null:
		thread = Thread.new()
		thread.start(self, "_cleanup", maze)
