class_name Player extends CharacterBody3D

signal paused


const MOUSE_SENSITIVITY = 0.0015; # TODO move to a globals/settings


@export var groundFriction = 4;
@export var jumpImpulse = 8;
@export var airAccel = 500;
@export var airSpeedCap = 30 / Globals.INCHES_PER_METER;
@export var groundAccel = 5; # Ground acceleration
@export var groundSpeedCap = 320 / Globals.INCHES_PER_METER; # Max walking speed on ground
@export var weapons : Array[Weapon] = [];
@export_range(0.0, 2500.0) var hookStrength = 1250; # Amount the player can influence their movement while grappling
@export_range(0.9, 1.0) var hookRangeShrinkRatio = 0.975; # How close the player needs to be to the hook anchor in order to shrink the hook length. Higher values are more forgiving
@export_range(0.01, 0.3) var hookRangeShrinkRate = 0.18; # Rate at which hook length shrinks when player gets closer to it. Higher values are more forgiving
@export_range(0.0, 1.0) var hookAirAccelFactor = 0.18; # How much to reduce player's airaccel while hooked
@export_range(100.0, 400.0) var hookMinLenSq = 200.0; # Smallest length (squared) to shrink hook to if player gets closer to it

var weapon : Weapon; # Currently equipped weapon
var pm; # PlayerMove script
var xy_speed; # XY (actually xz) speed of player, updated in _playerMove()
var z_speed; # Z (actually Y) speed of player, updated in _playerMove();
var rot_x = 0; # Cumulative rotation
var rot_y = 0; # Cumulative rotation
var inputDir : Vector3; # Direction of player's input (unit vector), flattened to XY plane
var inputDir3 : Vector3; # Direction of player's input (unit vector), no flattening -- includes vertical component
var dt; # Physics deltatime
var hooked : bool; # Whether or not the player is anchored to something using the grapplehook
var hook_pos : Vector3; # If hooked, location of anchor
var hook_lensq : float; # If hooked, squared length of hook
var hook_len : float; # If hooked, length of hook
var debug_sphere : MeshInstance3D; # If hooked, debug sphere showing radius of hook


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


func _ready() -> void:
	pm = load("res://scripts/playermovement.gd").new(self);
	Globals.player = self;
	#velocity = Vector3.ZERO;
	return;


func _physics_process(delta: float) -> void:
	dt = delta;
	var _inputDir2d = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
	inputDir = (self.transform.basis * Vector3(_inputDir2d.x, 0, _inputDir2d.y)).normalized();
	inputDir3 = (self.transform.basis * $Head.transform.basis * Vector3(_inputDir2d.x, 0, _inputDir2d.y)).normalized();
	if weapon:
		if weapon.single_shot and Input.is_action_just_pressed("primary_fire"): weapon.try_shoot(self)
		elif weapon.single_shot and Input.is_action_just_released("primary_fire"): weapon.stop_shoot(self);
		elif (!weapon.single_shot) and Input.is_action_pressed("primary_fire"): weapon.try_shoot(self);
	pm.move(dt);
	if hooked and (hook_lensq > hookMinLenSq) and (position.distance_squared_to(hook_pos) < hook_lensq * hookRangeShrinkRatio):
		hook_lensq = lerp(hook_lensq, position.distance_squared_to(hook_pos), hookRangeShrinkRate);
		hook_len = sqrt(hook_lensq);
		debug_sphere.mesh.height = hook_len * 2;
		debug_sphere.mesh.radius = hook_len;


func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("pause") and (!Globals.paused):
			get_viewport().set_input_as_handled();
			Globals.paused = true;
			paused.emit();
		elif Input.is_action_just_pressed("weapon0"): _equipWeapon(0);
		elif Input.is_action_just_pressed("weapon1"): _equipWeapon(1);
		elif Input.is_action_just_pressed("weapon2"): _equipWeapon(2);
		elif Input.is_action_just_pressed("weapon3"): _equipWeapon(3);
		elif Input.is_action_just_pressed("weapon4"): _equipWeapon(4);
	elif event is InputEventMouseMotion:
		_handleMouseMotionEvent(event);


func _handleMouseMotionEvent(event):
	rot_x -= event.relative.x * MOUSE_SENSITIVITY;
	rot_y -= event.relative.y * MOUSE_SENSITIVITY;
	rot_x = wrapf(rot_x, -PI, PI);
	rot_y = clampf(rot_y, -PI/2, PI/2);
	self.transform.basis = Basis();
	self.rotate_object_local(Vector3(0, 1, 0), rot_x);
	$Head.transform.basis = Basis();
	$Head.rotate_object_local(Vector3(1, 0, 0), rot_y);


func _equipWeapon(idx : int) -> void:
	if (idx >= weapons.size()): return;
	if weapon: weapon.abort_shoot(self);
	
	for child in $Head/WeaponContainer.get_children():
		$Head/WeaponContainer.remove_child(child);
	var weaponMesh = weapons[idx].model.instantiate();
	weapon = weapons[idx];
	$Head/WeaponContainer.add_child(weaponMesh);


func set_view_angle(right : float, up : float) -> void:
	rot_x = right;
	rot_y = up;
	self.transform.basis = Basis();
	self.rotate_object_local(Vector3(0, 1, 0), rot_x);
	$Head.transform.basis = Basis();
	$Head.rotate_object_local(Vector3(1, 0, 0), rot_y);


func attach_hook(pos : Vector3):
	hooked = true;
	airAccel /= 10;
	hook_pos = pos;
	hook_lensq = self.global_position.distance_squared_to(pos);
	hook_len = sqrt(hook_lensq);
	print("attached hook with sqlen %5.1f at position " % hook_lensq, pos);
	debug_sphere.mesh.height = hook_len * 2;
	debug_sphere.mesh.radius = hook_len;
	debug_sphere.position = pos;
	Globals.world.add_child(debug_sphere);


func detach_hook():
	hooked = false;
	airAccel *= 10;
	hook_lensq = 0;
	hook_len = 0;
	hook_pos = Vector3.ZERO;
	Globals.world.remove_child(debug_sphere);
	print("detached hook");
