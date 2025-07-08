extends Node3D

var RAY_LENGTH = 1000;
var sparkscn = preload("res://scenes/spark.tscn");

func shoot(shooter : CharacterBody3D) -> void:
	if shooter.has_node("Head/WeaponContainer"):
		var shooterHeadNode = shooter.get_node("Head");
		var shooterWeapNode = shooter.get_node("Head/WeaponContainer");
		var space_state = shooterHeadNode.get_world_3d().direct_space_state;
		var origin = shooterHeadNode.global_position;
		var target = -RAY_LENGTH * shooterHeadNode.global_transform.basis.z;
		var query = PhysicsRayQueryParameters3D.create(origin, target);
		query.collide_with_areas = true;
		query.exclude = [shooter];
		var result = space_state.intersect_ray(query);
		if (result):
			var b = sparkscn.instantiate();
			b.position = result.position;
			Globals.world.add_child(b);
	
	print("default_shoot_action.gd -> shoot()");
