extends Area

var value

func _on_Target_body_entered(body):
	if "Pertti" in body.name:
		queue_free()