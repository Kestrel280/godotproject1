class_name Weapon extends Resource

@export_subgroup("Aesthetics")
@export var model : PackedScene;
@export var shoot_sound_path : String;

@export_subgroup("Properties")
@export var ammo : int = 10;
@export var reload_time : float = 2.0;
@export var shoot_script : GDScript;

var _loaded;
var shoot_script_instance;


func _load():
	_loaded = true;
	shoot_script_instance = shoot_script.new()


func shoot():
	if (!_loaded): _load();
	shoot_script_instance.shoot();
