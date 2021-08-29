extends Node2D


const INITIAL_DIRECTION = Vector2(1,0)

var direction = INITIAL_DIRECTION
var shooting_acceleration = 1000

func rotate_180():
	direction = direction * -1
	$Sprite.flip_h = true

