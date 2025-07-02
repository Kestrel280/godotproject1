extends Node3D

var pauseMenuScenePacked = preload("res://pause_menu.tscn");
var pauseMenuScene;

func _on_player_paused() -> void:
	pauseMenuScene = pauseMenuScenePacked.instantiate();
	add_child(pauseMenuScene); # Replace with function body.


func _on_player_unpaused() -> void:
	if pauseMenuScene: pauseMenuScene.queue_free();
