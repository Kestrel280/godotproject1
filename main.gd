extends Node

var playerScenePacked = preload("res://scenes/player.tscn");
var pauseMenuScenePacked = preload("res://scenes/pause_menu.tscn");
var gameUiScenePacked = preload("res://scenes/game_ui.tscn");


func _ready() -> void:
	Globals.root = self;
	change_level("map1");
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);


# --- Signal handlers --- #
func _on_ui_container_paused() -> void:
	get_tree().paused = true;
	$UiContainer.add_child(pauseMenuScenePacked.instantiate());
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);


func _on_ui_container_unpaused() -> void:
	if $UiContainer.has_node("PauseMenu"): $UiContainer.get_node("PauseMenu").queue_free();
	get_tree().paused = false;
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);


func _on_ui_container_player_requested_map_load(mapName: String) -> void:
	change_level(mapName);


# --- Game management --- #
func change_level(mapName : String) -> void:
	load_map(mapName);
	spawn_player();


func load_map(mapName : String) -> void:
	var mapPath : String = "res://maps/%s.tscn" % mapName;
	var mapScn : PackedScene = load(mapPath);
	
	# Clean up current world, player, and UI nodes
	if Globals.world: Globals.world.queue_free();
	if Globals.player: Globals.player.queue_free();
	for ui_node in $UiContainer.get_children(): ui_node.queue_free();

	# Load new world and player
	var map = mapScn.instantiate();
	add_child(map);
	
	# Register new world and player to globals
	Globals.world = map;


func spawn_player() -> void:
	# If there's no loaded world, we can't spawn a player
	if !Globals.world: return;

	# Construct the player and add it to the tree
	var player : Player = playerScenePacked.instantiate();
	add_child(player);
		
	# Place player at spawn location, if there is one
	if Globals.world.has_node("SpawnPoint"):
		player.global_transform = Globals.world.get_node("SpawnPoint").global_transform;
		player.set_view_angle(0, 0);
	
	# Register player to Globals singleton
	Globals.player = player;
	
	# Create a UI node for the player
	var gameUi : Control = gameUiScenePacked.instantiate();
	$UiContainer.add_child(gameUi);
