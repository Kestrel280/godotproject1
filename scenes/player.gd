class_name Player extends CharacterBody3D

signal paused
signal unpaused


const MOUSE_SENSITIVITY = 0.0025; # TODO move to a globals/settings


@export var groundFriction = 4;
@export var jumpImpulse = 8;
@export var airAccel = 1500;
@export var airSpeedCap = 30 / Globals.INCHES_PER_METER;
@export var groundAccel = 5; # Ground acceleration
@export var groundSpeedCap = 320 / Globals.INCHES_PER_METER; # Max walking speed on ground
@export var weapons : Array[Weapon] = [];


var weapon : Weapon; # Currently equipped weapon
var pm; # PlayerMove script
var xy_speed; # XY (actually xz) speed of player, updated in _playerMove()
var z_speed; # Z (actually Y) speed of player, updated in _playerMove();
var inControl; # Player has control
var rot_x = 0; # Cumulative rotation
var rot_y = 0; # Cumulative rotation
var inputDir : Vector3; # Direction of player's input (unit vector)
var dt; # Physics deltatime


func _ready() -> void:
	pm = load("res://scripts/playermovement.gd").new(self);
	Globals.player = self;
	_takeControl();
	velocity = Vector3.ZERO;
	return;


func _physics_process(delta: float) -> void:
	dt = delta;
	var _inputDir2d = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
	inputDir = (self.transform.basis * Vector3(_inputDir2d.x, 0, _inputDir2d.y)).normalized();
	if weapon:
		if weapon.single_shot and Input.is_action_just_pressed("primary_fire"): weapon.try_shoot(self)
		elif (!weapon.single_shot) and Input.is_action_pressed("primary_fire"): weapon.try_shoot(self);
	pm.move(dt);


func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("pause"):
			if !inControl: _takeControl();
			else: _releaseControl();
		elif Input.is_action_just_pressed("weapon0"): _equipWeapon(0);
		elif Input.is_action_just_pressed("weapon1"): _equipWeapon(1);
		elif Input.is_action_just_pressed("weapon2"): _equipWeapon(2);
	elif event is InputEventMouseMotion:
		if inControl:
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


func _takeControl():
	inControl = true;
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	set_physics_process(true);
	unpaused.emit();


func _releaseControl():
	inControl = false;
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	set_physics_process(false);
	paused.emit();
	

func _equipWeapon(idx : int) -> void:
	if (idx >= weapons.size()): return;
	
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
