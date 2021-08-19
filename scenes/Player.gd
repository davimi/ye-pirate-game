extends KinematicBody2D

var screen_size

# movement vars
const MIN_TURN_SPEED = 50
const MAX_TURN_SPEED = 200

export var speed: int = 120
var rotation_speed: float = 0.0174533
var acceleration = 0.05
var deceleration = 0.03

var motion = Vector2()  # The player's normalized movement vector
var movement = Vector2() # The player's actual movement vector


func _ready():
	screen_size = get_viewport_rect().size
	
func move_player(delta):
	var movedir = _get_rotation(delta)
	
	if Input.is_action_pressed("ui_up"):
		motion = motion.linear_interpolate(movedir, acceleration)
	else:
		motion = motion.linear_interpolate(Vector2(0,0), deceleration)
	
	movement = motion * speed * delta
	move_and_collide(movement)


func _get_rotation(delta):
	var turn_speed = _get_turn_speed()
	if Input.is_action_pressed("ui_left"):
		rotation_degrees -= turn_speed * delta
	if Input.is_action_pressed("ui_right"):
		rotation_degrees += turn_speed * delta
	
	var movedir = Vector2(0,1).rotated(rotation) # ship is facing Vector(0,1) by default
	return movedir

# TODO: the turn speed should be higher if the ship moves faster
func _get_turn_speed():
	var speed_scalar: float = (motion.abs().x + motion.abs().y) / 2 
	return lerp(MIN_TURN_SPEED, MAX_TURN_SPEED, speed_scalar)
	
func _physics_process(delta):
	move_player(delta)

