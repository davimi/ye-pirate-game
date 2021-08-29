extends RigidBody2D


var hit_points = 3

func handle_hit():
	hit_points -= 1
	
	if hit_points <= 1:
		$SailDamaged.visible = true
		$SailNormal.visible = false
	if hit_points <= 0:
		queue_free()
