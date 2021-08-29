extends Area2D


func _on_ShipwreckedPerson_body_entered(body):
	queue_free()

func _physics_process(delta):
	$AnimationPlayer.play("idle")
	
