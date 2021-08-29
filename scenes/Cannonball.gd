extends RigidBody2D


var explosion = preload("res://scenes/Explosion.tscn")

func _on_Cannonball_body_entered(body):
	explode()
	body.handle_hit()
	queue_free()

func explode():
	var explosion_instance = explosion.instance()
	explosion_instance.position = get_global_position()
	get_tree().get_root().add_child(explosion_instance)
