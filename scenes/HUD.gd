extends CanvasLayer


export var num_shipwrecked_saved: int

func _ready():
	num_shipwrecked_saved = 0
	$NumShipwrecked.text = str(num_shipwrecked_saved)


func increment_num_shipwrecked(increment: int):
	num_shipwrecked_saved += increment
	$NumShipwrecked.text = str(num_shipwrecked_saved)


func _on_ShipwreckedPerson_body_entered(body):
	increment_num_shipwrecked(1)
