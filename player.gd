class_name Player extends CharacterBody3D

signal paused
signal unpaused

const INCHES_PER_METER : float = 39.3701;
const GROUND_NORMAL_THRESHOLD : float = 0.7; # If y component of surface normal is above this value, treat is as a floor

var weapon : Weapon;
@export var weapons : Array[Weapon] = [];

@export var groundFriction = 4;
@export var mass = 70;

@export var jumpImpulse = 8;
@export var airAccel = 15000;
@export var airSpeedCap = 30 / INCHES_PER_METER;
@export var groundFrictionStopSpeedThreshold = 0.5 / INCHES_PER_METER; # On ground, if speed less than this value, just set to 0
@export var groundAccel = 5; # Ground acceleration
@export var groundSpeedCap = 320 / INCHES_PER_METER; # Max walking speed on ground
var MOUSE_SENSITIVITY = 0.0025; # TODO move to a globals/settings

var xy_speed; # XY (actually xz) speed of player, updated in _playerMove()
var z_speed; # Z (actually Y) speed of player, updated in _playerMove();
var inControl; # Player has control
var rot_x = 0; # Cumulative rotation
var rot_y = 0; # Cumulative rotation
var onGround : bool; # Player is on ground
var inputDir : Vector3; # Direction of player's input (unit vector)
var outWishVel : Vector3; # Per-frame desired movement vector
var dt; # Physics deltatime


func _ready() -> void:
	Globals.player = self;
	_takeControl();
	velocity = Vector3.ZERO;
	return;


func _physics_process(delta: float) -> void:
	dt = delta;

	var _inputDir2d = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
	inputDir = ($Pivot.transform.basis * Vector3(_inputDir2d.x, 0, _inputDir2d.y)).normalized();
	_playerMove();


func _playerMove() -> void:
	outWishVel = Vector3(velocity);
	outWishVel += get_gravity() * dt;
	
	if onGround:
		if Input.is_action_pressed("jump") and _tryJump():
			_airMove();
		else:
			_groundMove()
	else:
		_airMove();
		
	velocity = outWishVel;
	var collision = move_and_collide(velocity * dt, true); # TEST for collision, do not actually perform
	if collision:
		var severity = abs(velocity.normalized().dot(collision.get_normal())); # 0-1: higher = more severe collision
		velocity = velocity.slide(collision.get_normal());
		onGround = collision.get_normal().y > GROUND_NORMAL_THRESHOLD;
	else:
		onGround = false;
	move_and_slide()

	Globals.player.xy_speed = Vector2(velocity.x, velocity.z).length();
	Globals.player.z_speed = velocity.y;
	
	return;


func _airMove() -> void:
	_applyAirAccel();


func _applyAirAccel():
	var curSpeedInInputDir = inputDir.dot(velocity);
	var maxSpeedToAdd = max(0, airSpeedCap - curSpeedInInputDir);
	var speedToAddInInputDir = clampf(airAccel * airSpeedCap * dt, 0.0, maxSpeedToAdd); # TODO multiplication by airSpeedCap should probably be an analog value
	outWishVel += speedToAddInInputDir * inputDir;


func _groundMove() -> void:
	_applyGroundFriction(); # Apply friction, updating outWishVel
	_applyGroundAccel();	# Apply ground acceleration, updating outWishVel
	

func _applyGroundFriction() -> void:
	var wishSpeed = outWishVel.length();
	if wishSpeed < groundFrictionStopSpeedThreshold:
		outWishVel = Vector3.ZERO;
		return;
	var speedScale = 1 - (getGroundFriction() * dt);
	outWishVel = outWishVel * speedScale;


func _applyGroundAccel() -> void:
	var curSpeedInInputDir = inputDir.dot(velocity);
	var maxSpeedToAddInInputDir = groundSpeedCap - curSpeedInInputDir;
	var speedToAddInInputDir = clampf(groundAccel * groundSpeedCap * dt, 0.0, maxSpeedToAddInInputDir);  # TODO multiplication by groundSpeedCap should probably be an analog value
	outWishVel += speedToAddInInputDir * inputDir;
	

func _tryJump() -> bool:
	outWishVel.y = jumpImpulse;
	return true;


func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("pause"): toggleInControl();
		elif Input.is_action_just_pressed("weapon0"): _equipWeapon(0);
		elif Input.is_action_just_pressed("weapon1"): _equipWeapon(1);
	elif event is InputEventMouseMotion:
		if inControl:
			_handleMouseMotionEvent(event);
	elif event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT):
			if weapon:
				weapon.shoot();


func _handleMouseMotionEvent(event):
	rot_x -= event.relative.x * MOUSE_SENSITIVITY;
	rot_y -= event.relative.y * MOUSE_SENSITIVITY;
	rot_x = wrapf(rot_x, -PI, PI);
	rot_y = clampf(rot_y, -PI/2, PI/2);
	$Pivot.transform.basis = Basis();
	$Pivot.rotate_object_local(Vector3(0, 1, 0), rot_x);
	$Pivot/Camera.transform.basis = Basis();
	$Pivot/Camera.rotate_object_local(Vector3(1, 0, 0), rot_y);


func getGroundFriction() -> float:
	return groundFriction;


func toggleInControl() -> void:
	if !inControl: _takeControl();
	else: _releaseControl();


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
	
	for child in $Pivot/Camera/WeaponContainer.get_children():
		$Pivot/Camera/WeaponContainer.remove_child(child);
	var weaponMesh = weapons[idx].model.instantiate();
	weapon = weapons[idx];
	$Pivot/Camera/WeaponContainer.add_child(weaponMesh);
