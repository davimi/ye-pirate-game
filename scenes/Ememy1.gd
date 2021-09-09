extends KinematicBody2D


onready var path_follow: PathFollow2D = get_parent()

var hit_points = 3
var speed_idle = 100
var speed_pursuing = 120

enum State {IDLE, PURSUING, RETREATING}
var current_state = 0

var player: KinematicBody2D

var cannon_balls = preload("res://scenes/CannonballEnemy.tscn")
const SHOT_ACCELERATION = 600
var can_shoot = true
var fire_rate = 2

func handle_hit():
	hit_points -= 1
	
	if hit_points <= 1:
		$SailDamaged.visible = true
		$SailNormal.visible = false
	if hit_points <= 0:
		queue_free()
	
func _physics_process(delta):
	# When this node is an instance of a pathfollow2d, it will be located relastive to the parent and also have the relative rotation

	match current_state:
		State.IDLE:
			path_follow.set_offset(path_follow.get_offset() + speed_idle * delta)
		State.PURSUING:
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


func _on_PlayerDetection_body_entered(body):
	if player:
		return
	player = body
	current_state = State.PURSUING


func _on_PlayerDetection_body_exited(body):
	current_state = State.IDLE
	if body == player:
		player = null

