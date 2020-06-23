extends Area

var value

func _on_Target_body_entered(body):
	if "Pertti" in body.name:
		body.update_score(10, false)
		queue_free()
