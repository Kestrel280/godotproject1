extends Node3D

var RAY_LENGTH = 1000;
var debug_sphere : MeshInstance3D;


func shoot(shooter : CharacterBody3D) -> void:
	if shooter.has_node("Head/WeaponContainer"):
		var shooterHeadNode = shooter.get_node("Head");
		var shooterWeapNode = shooter.get_node("Head/WeaponContainer");
		var space_state = shooterHeadNode.get_world_3d().direct_space_state;
		var origin = shooterHeadNode.global_position;
		var target = shooterHeadNode.global_position - RAY_LENGTH * shooterHeadNode.global_transform.basis.z;
		var query = PhysicsRayQueryParameters3D.create(origin, target);
		query.collide_with_areas = true;
		query.exclude = [shooter];
		var result = space_state.intersect_ray(query);
		if (result):
			if (shooter.has_method("attach_hook")):
				shooter.attach_hook(result.position);


func stop_shoot(shooter: CharacterBody3D) -> void:
	Globals.world.remove_child(debug_sphere);
	if (shooter.has_method("detach_hook")):
		shooter.detach_hook();


func abort_shoot(shooter : CharacterBody3D) -> void:
	stop_shoot(shooter);
