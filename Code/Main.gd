extends Node2D

export (PackedScene) var Maze

func _on_Configuration_configuration_done():
	var config = $CanvasLayer/Configuration
	
	config.visible = false
	var maze = Maze.instance()

	maze.set_algorythm(config.get_algorythm())
	$node.add_child(maze)
	maze.connect("on_game_finished", self, "on_finish")
	maze.start_generation(config.get_dim())

func on_finish():
	$CleanupTimer.start()

func _on_CleanupTimer_timeout():
	var maze = $node.get_child(0)
	maze.stop()
	maze.disconnect("on_game_finished", self, "on_finish")
	$node.call_deferred("remove_child", maze)
	maze.queue_free()
	$CanvasLayer/Configuration.visible = true
