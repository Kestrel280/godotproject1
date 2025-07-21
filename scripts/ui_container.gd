extends Node


signal paused;
signal unpaused;
signal player_requested_map_load(mapName : String);


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("pause"):
			Globals.paused = !Globals.paused;
			if Globals.paused: paused.emit();
			else: unpaused.emit();
			get_viewport().set_input_as_handled();
		elif Input.is_action_just_pressed("debug_load_map1"):
			player_requested_map_load.emit("map1");
		elif Input.is_action_just_pressed("debug_load_map2"):
			player_requested_map_load.emit("map2");
