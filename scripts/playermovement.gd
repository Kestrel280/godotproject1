extends Node


const GROUND_NORMAL_THRESHOLD : float = 0.7; # If y component of surface normal is above this value, treat is as a floor
const GROUND_FRICTION_STOP_SPEED_THRESHOLD = 0.5 / Globals.INCHES_PER_METER; # On ground, if speed less than this value, just set to 0
const INCHES_PER_METER : float = 39.3701;


var dt;
var onGround : bool; # Player is on ground
var outWishVel : Vector3; # Per-frame desired movement vector
var player : Player;


func _init(_player : Player):
	player = _player;


func move(_dt : float) -> void:
	dt = _dt;
	outWishVel = Vector3(player.velocity);
	outWishVel += player.get_gravity() * dt;
	
	if onGround:
		if Input.is_action_pressed("jump") and _tryJump():
			_airMove();
		else:
			_groundMove()
	else:
		_airMove();
		
	player.velocity = outWishVel;
	var collision = player.move_and_collide(player.velocity * dt, true); # TEST for collision, do not actually perform
	if collision:
		player.velocity = player.velocity.slide(collision.get_normal());
		onGround = collision.get_normal().y > GROUND_NORMAL_THRESHOLD;
	else:
		onGround = false;
	player.move_and_slide()

	player.xy_speed = Vector2(player.velocity.x, player.velocity.z).length();
	player.z_speed = player.velocity.y;
	
	return;


func _airMove():
	var curSpeedInInputDir = player.inputDir.dot(player.velocity);
	var maxSpeedToAdd = max(0, player.airSpeedCap - curSpeedInInputDir);
	var speedToAddInInputDir = clampf(player.airAccel * player.airSpeedCap * dt, 0.0, maxSpeedToAdd); # TODO multiplication by airSpeedCap should probably be an analog value
	outWishVel += speedToAddInInputDir * player.inputDir;


func _groundMove() -> void:
	_applyGroundFriction(); # Apply friction, updating outWishVel
	_applyGroundAccel();	# Apply ground acceleration, updating outWishVel
	

func _applyGroundFriction() -> void:
	var wishSpeed = outWishVel.length();
	if wishSpeed < GROUND_FRICTION_STOP_SPEED_THRESHOLD:
		outWishVel = Vector3.ZERO;
		return;
	var speedScale = 1 - (player.groundFriction * dt);
	outWishVel = outWishVel * speedScale;


func _applyGroundAccel() -> void:
	var curSpeedInInputDir = player.inputDir.dot(player.velocity);
	var maxSpeedToAddInInputDir = player.groundSpeedCap - curSpeedInInputDir;
	var speedToAddInInputDir = clampf(player.groundAccel * player.groundSpeedCap * dt, 0.0, maxSpeedToAddInInputDir);  # TODO multiplication by groundSpeedCap should probably be an analog value
	outWishVel += speedToAddInInputDir * player.inputDir;
	

func _tryJump() -> bool:
	outWishVel.y = player.jumpImpulse;
	return true;
