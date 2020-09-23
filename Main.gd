extends Node2D

var thread
export (PackedScene) var Maze

func _on_Configuration_configuration_done():
	var config = $CanvasLayer/Configuration
	
	config.visible = false
	var maze = Maze.instance()

	maze.set_algorythm(config.get_algorythm())
	$node.add_child(maze)
	maze.connect("on_game_finished", self, "on_finish")
	maze.start_generation(config.get_dim())

#cleanup after maze removal
func _cleanup(maze):
	maze.stop()
	$node.call_deferred("remove_child", maze)
	maze.disconnect("on_game_finished", self, "on_finish")
	maze.queue_free()
	$CanvasLayer/Configuration.visible = true
	thread.wait_to_finish()

func on_finish():
	#print("Finish")
	var maze = $node.get_node("Maze")
	if maze != null:
		thread = Thread.new()
		thread.start(self, "_cleanup", maze)
