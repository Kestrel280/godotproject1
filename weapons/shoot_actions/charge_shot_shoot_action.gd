extends Node


var charging : bool = false;

func shoot(shooter : CharacterBody3D) -> void:
	charging = true;
	var bullet = load("res://scenes/chargeshot.tscn").instantiate();
	bullet.position = Vector3(0.0, 0.0, 0.5);

	shooter.get_node("Head/WeaponContainer").add_child(bullet);
	
	var scale : float = 1.0;
	var base_radius : float = bullet.get_node("Model").mesh.radius;
	var base_light_energy : float = bullet.get_node("Light").light_energy;
	var base_light_radius : float = bullet.get_node("Light").omni_range;
	var impulse = 30.0;
	while(charging):
		await shooter.get_tree().physics_frame;
		scale = min(scale + 0.04, 3.0);
		bullet.get_node("Model").mesh.radius = base_radius * scale;
		bullet.get_node("Model").mesh.height = base_radius * scale * 2;
		bullet.get_node("Light").light_energy = base_light_energy * scale;
		bullet.get_node("Light").omni_range = base_light_radius * scale;
	
	var pos = bullet.global_position;
	shooter.get_node("Head/WeaponContainer").remove_child(bullet);
	bullet.position = Vector3.ZERO;
	bullet.global_position = pos;
	Globals.world.add_child(bullet);
	bullet.launch(shooter.get_node("Head/WeaponContainer").global_basis.z, impulse * scale);


func stop_shoot(shooter : CharacterBody3D) -> void:
	charging = false;
