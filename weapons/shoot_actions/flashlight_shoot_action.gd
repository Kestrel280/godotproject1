extends Node


var _enabled : bool = false;
var light : SpotLight3D;


func shoot(shooter : CharacterBody3D) -> void:
	if _enabled: _turnOff();
	else: _turnOn(shooter);


func abort_shoot(shooter : CharacterBody3D) -> void:
	_turnOff();


func _turnOn(shooter : CharacterBody3D):
	_enabled = true;
	light = SpotLight3D.new();
	light.spot_range = 40.0;
	light.spot_attenuation = 0.6;
	light.spot_angle = 25.0;
	light.spot_angle_attenuation = 2.0;
	light.light_energy = 2.0;
	light.position = shooter.get_node("Head/WeaponContainer").position;
	shooter.get_node("Head").add_child(light);
	print("on");


func _turnOff():
	_enabled = false;
	if light: light.queue_free();
	print("off");
