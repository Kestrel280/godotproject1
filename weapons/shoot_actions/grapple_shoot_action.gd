extends Node3D

var RAY_LENGTH = 1000;
var debug_sphere : MeshInstance3D;


func _init() -> void:
	var material = StandardMaterial3D.new();
	material.albedo_color = Color(1.0, 1.0, 1.0, 1);
	material.albedo_texture = load("res://textures/crosshair.png");
	material.uv1_scale = Vector3(30, 30, 30);
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA;
	material.cull_mode = BaseMaterial3D.CULL_DISABLED;
	material.disable_receive_shadows = true;
	debug_sphere = MeshInstance3D.new();
	debug_sphere.mesh = SphereMesh.new();
	debug_sphere.set_surface_override_material(0, material);
	


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
				debug_sphere.mesh.height = shooter.hook_len * 2;
				debug_sphere.mesh.radius = shooter.hook_len;
				debug_sphere.position = result.position;
				Globals.world.add_child(debug_sphere);


func stop_shoot(shooter: CharacterBody3D) -> void:
	Globals.world.remove_child(debug_sphere);
	if (shooter.has_method("detach_hook")):
		shooter.detach_hook();


func abort_shoot(shooter : CharacterBody3D) -> void:
	stop_shoot(shooter);
