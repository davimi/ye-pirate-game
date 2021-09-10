extends KinematicBody2D

var screen_size

# movement vars
const MIN_TURN_SPEED = 50
const MAX_TURN_SPEED = 200

export var speed: int = 140
var rotation_speed: float = 0.0174533
var acceleration = 0.05
var deceleration = 0.03


var motion = Vector2()  # The player's normalized movement vector
var velocity = Vector2() # The player's actual movement vector
const DEFAULT_FACING_DIRECTION = Vector2(0,1)

var cannon_balls = preload("res://scenes/Cannonball.tscn")
const SHOT_ACCELERATION = 700
var can_shoot_left = true
var can_shoot_right = true
var fire_rate = 0.5

signal player_hit(hit_points_left)
const MAX_HITPOINTS = 8
var hit_points: int = MAX_HITPOINTS


func _ready():
	screen_size = get_viewport_rect().size
	$CannonRight.rotate_180()
	
	$WatergustParticles.speed_scale = 0
	set_damage_visuals(false)

func set_damage_visuals(is_damaged: bool):
	$HullDamaged.visible = is_damaged
	$SailDamaged. visible = is_damaged
	$Sail.visible = !is_damaged
	$Hull.visible = !is_damaged

func move_player(delta):
	var movedir = _get_rotation(delta)
	
	if Input.is_action_pressed("ui_up"):
		motion = motion.linear_interpolate(movedir, acceleration)
	else:
		motion = motion.linear_interpolate(Vector2(0,0), deceleration)
	
	velocity = motion * speed * delta
	move_and_collide(velocity)
	set_gust_behviour(motion.abs().length())


func _get_rotation(delta):
	var turn_speed = _get_turn_speed()
	if Input.is_action_pressed("ui_left"):
		rotation_degrees -= turn_speed * delta
	if Input.is_action_pressed("ui_right"):
		rotation_degrees += turn_speed * delta
	
	var movedir = DEFAULT_FACING_DIRECTION.rotated(rotation) # ship is facing Vector(0,1) by default
	return movedir


func _get_turn_speed():
	var speed_scalar: float = (motion.abs().x + motion.abs().y) / 2 
	return lerp(MIN_TURN_SPEED, MAX_TURN_SPEED, speed_scalar)

func shoot_left():
	shoot_direction(Vector2(1,0).rotated(rotation), $CannonLeft.position)
	can_shoot_left = false
	yield(get_tree().create_timer(fire_rate), "timeout")
	can_shoot_left =  true

func shoot_right(): 
	shoot_direction(Vector2(-1,0).rotated(rotation), $CannonRight.position)
	can_shoot_right = false
	yield(get_tree().create_timer(fire_rate), "timeout")
	can_shoot_right = true

func shoot_direction(direction: Vector2, from_position: Vector2):
	var projectile = cannon_balls.instance()
	add_child(projectile)
	projectile.position = from_position
	projectile.apply_impulse(Vector2(), direction * SHOT_ACCELERATION)

func handle_hit():
	hit_points -= 1
	emit_signal("player_hit", hit_points, MAX_HITPOINTS)
	if hit_points <= (MAX_HITPOINTS / 2):
		set_damage_visuals(true)
	if hit_points <= 0:
		queue_free()

func set_gust_behviour(scale: float):
	$WatergustParticles.speed_scale = scale * 1.2
	$WatergustParticles2.speed_scale = scale * 1.2
	if scale <= 0.15:
		$WatergustParticles.emitting = false
		$WatergustParticles2.emitting = false
	else:
		$WatergustParticles.emitting = true
		$WatergustParticles2.emitting = true
	
func _physics_process(delta):
	move_player(delta)

func _process(delta):
	
	if Input.is_action_just_pressed("shoot_left") and can_shoot_left:
		shoot_left()

	elif Input.is_action_just_pressed("shoot_right") and can_shoot_right:
		shoot_right()
		
