extends Node2D


const LEVEL_WIDTH = 1280
const LEVEL_HEIGHT = 800

const INITIAL_NUMBER_SHIPWRECKED = 3
var number_shipwrecked_saved: int = 0


func _ready():
	$Sea.position.x = LEVEL_WIDTH / 2
	$Sea.position.y = LEVEL_HEIGHT / 2


func _on_ShipwreckedPerson_body_entered(body):
	print("Person collected")
	number_shipwrecked_saved += 1
	if number_shipwrecked_saved == INITIAL_NUMBER_SHIPWRECKED:
		get_tree().change_scene("res://scenes/Level1.tscn")
	

func reload_level():
	get_tree().change_scene("res://Level0.tscn")


func _on_Ememy1_body_entered(body):
	print("sdg")
	body.handleDamage()
