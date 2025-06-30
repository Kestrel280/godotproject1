extends CharacterBody3D

const INCHES_PER_METER : float = 39.3701;

@export var groundFriction = 4;
@export var mass = 70;

@export var jumpImpulse = 4;
@export var airAccel = 150;
@export var airSpeedCap = 30 / INCHES_PER_METER;
@export var groundFrictionStopSpeedThreshold = 0.5 / INCHES_PER_METER; # On ground, if speed less than this value, just set to 0
@export var groundAccel = 5; # Ground acceleration
@export var groundSpeedCap = 320 / INCHES_PER_METER; # Max walking speed on ground
var MOUSE_SENSITIVITY = 0.004; # TODO move to a globals/settings

var rot_x = 0	# Cumulative rotation
var rot_y = 0	# Cumulative rotation
var inputDir : Vector3;
var outWishVel : Vector3;
var dt;

func _ready() -> void:
	velocity = Vector3.ZERO;
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	return;

func _physics_process(delta: float) -> void:
	dt = delta;

	var _inputDir2d = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
	inputDir = ($Pivot.transform.basis * Vector3(_inputDir2d.x, 0, _inputDir2d.y)).normalized();
	_playerMove();


func _playerMove() -> void:
	outWishVel = Vector3(velocity);
	if not is_on_floor():
		_airMove();
	else:
		if Input.is_action_pressed("jump"):
			_jump()
			_airMove()
		else:
			_groundMove()
	velocity = outWishVel;
	Globals.playerSpeedXy = Vector2(velocity.x, velocity.z).length();
	move_and_slide();
	return;


func _airMove() -> void:
	_applyAirAccel();
	outWishVel += get_gravity() * dt;


func _applyAirAccel():
	var curSpeedInInputDir = inputDir.dot(velocity);
	var maxSpeedToAdd = max(0, airSpeedCap - curSpeedInInputDir);
	var speedToAddInInputDir = clampf(airAccel * airSpeedCap * dt, 0.0, maxSpeedToAdd); # TODO multiplication by airSpeedCap should probably be an analog value
	print("curSpeedInInputDir = %3.1f | maxSpeedToAdd = %3.1f | speedToAddInInputDir = %3.1f" % [curSpeedInInputDir, maxSpeedToAdd, speedToAddInInputDir]);
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
	

func _jump() -> void:
	outWishVel.y += jumpImpulse;


func _input(event):
	if event is InputEventMouseMotion:
		_handleMouseMotionEvent(event);


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
