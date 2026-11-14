extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Player fell out of bounds! GAME OVER")
		
		# Trigger the unified death sequence from player.gd
		if body.has_method("die"):
			body.die()
			body.hide() 
			
		else:
			body.queue_free()
			await get_tree().create_timer(2.0).timeout
			get_tree().reload_current_scene()
	elif body.name == "Anomaly":
		print("Anomaly fell out of bounds! VICTORY")
		if body.has_method("die"):
			body.die()
