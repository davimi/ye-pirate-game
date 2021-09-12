extends KinematicBody2D


onready var path_follow: PathFollow2D = get_parent()

var hit_points = 3

enum State {PATROLLING, PURSUING, RETREATING, TURNING}
const NOTICE_SCALAR = 1.0 # rate at which notice radius increases
var current_state = State.PATROLLING
var return_position: Vector2 = get_global_position()
var speed_patrolling = 100
var speed_pursuing = 4000 # why so high?
const MIN_DISTANCE_TO_PLAYER = 120
var pursuing_rotation: float = 0
var elapsed_angle_lerp: float = 10

var player: KinematicBody2D

var cannon_balls = preload("res://scenes/CannonballEnemy.tscn")
const SHOT_ACCELERATION = 600
var can_shoot = true
var fire_rate = 2


func handle_hit():
	hit_points -= 1
	
	change_detect_radius(NOTICE_SCALAR)
	
	if hit_points == 2:
		$SailDamaged.visible = true
		$SailNormal.visible = false
	if hit_points == 1:
		$Hull.visible = false
		$HullDamaged.visible = true
	if hit_points <= 0:
		queue_free()

func _on_PlayerDetection_body_entered(body):
	if player:
		return
	player = body
	if current_state == State.PATROLLING:
		return_position = get_global_position()
	current_state = State.PURSUING

func _on_PlayerDetection_body_exited(body):
	current_state = State.TURNING
	pursuing_rotation = get_global_rotation()
	change_detect_radius(1.0)
	if body == player:
		player = null

func shoot_at_player():
	$FrontCannon.look_at(player.position) 
	var aim_vector = (player.get_global_position() - $FrontCannon.get_global_position()).normalized() * rand_range(0.8, 1.2)
	if can_shoot:
		var projectile = cannon_balls.instance()
		add_child(projectile)
		projectile.position = $FrontCannon.position
		projectile.apply_impulse(Vector2(), aim_vector * SHOT_ACCELERATION)
		can_shoot = false
		yield(get_tree().create_timer(fire_rate), "timeout")
		can_shoot = true

func pursue_player(delta: float):
	if player:
		if (player_in_pursue_range()):
			look_at(player.get_global_position())
			rotate_with_sprite_correction()
			move_and_slide((player.get_global_position() - get_global_position()).normalized() * speed_pursuing * delta)

func player_in_pursue_range() -> bool:
	var distance_from_last_patrolling_point = (get_global_position() - return_position).length()
	var distance_to_player = (player.get_global_position() - get_global_position()).length()
	if (distance_from_last_patrolling_point <= $PlayerDetection/DetectRadius.shape.radius) and (distance_to_player > MIN_DISTANCE_TO_PLAYER):
		return true
	else:
		return false
		
func change_detect_radius(scale: float):
	get_node("PlayerDetection/DetectRadius").scale.x = scale
	get_node("PlayerDetection/DetectRadius").scale.y = scale
	
func set_gust_behviour(switch: bool):
	$WatergustParticles.emitting = switch
	$WatergustParticles2.emitting = switch
	
func return_to_starting_point(from: Vector2, delta: float):
	look_at(return_position)
	rotate_with_sprite_correction()
	move_and_slide((return_position - from).normalized() * speed_pursuing * delta)

# sprite looks downward
func rotate_with_sprite_correction():
		rotate(3 * PI / 2)
		
func _physics_process(delta):
	# When this node is an instance of a pathfollow2d, it will be located relastive to the parent and also have the relative rotation
	match current_state:
		State.PATROLLING:
			$DebugText.text = "PATROLLING"
			path_follow.set_offset(path_follow.get_offset() + speed_patrolling * delta)
			set_rotation(3 * PI / 2)
			set_gust_behviour(true)
		State.PURSUING:
			$DebugText.text = "PURSUING"
			set_gust_behviour(true)
			change_detect_radius(NOTICE_SCALAR)
			shoot_at_player()
			pursue_player(delta)
		State.RETREATING:
			$DebugText.text = "RETREATING"
			set_gust_behviour(true)
			if (get_global_position() - return_position).length() <= 3:
				current_state = State.PATROLLING
			else:
				return_to_starting_point(get_global_position(), delta)
		State.TURNING:
			$DebugText.text = "TURNING"
			var currentRotation = get_global_rotation()
			print("lerp: ", lerp_angle(currentRotation, pursuing_rotation, elapsed_angle_lerp))
			print("pursuing rot: ", pursuing_rotation)
			rotation = lerp_angle(currentRotation, pursuing_rotation, elapsed_angle_lerp)
			elapsed_angle_lerp += delta / 5
			if (abs(currentRotation - pursuing_rotation) <= 0.1):
				elapsed_angle_lerp = 0.01
				current_state = State.RETREATING
			




