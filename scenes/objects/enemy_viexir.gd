extends RigidBody2D

var can_explode: bool = false 
var base_damage: int = 10 

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	can_explode = true

func _on_body_entered(body: Node) -> void:
	if not can_explode:
		return
		
	if body.has_method("start_turn"):
		return 
		
	print("Bottle shattered! Hit: %s" % body.name)
	AudioManager.play_hit()
	
	if body.name == "Player":
		if Global.is_reflecting_shield:
			Global.is_reflecting_shield = false
			print("🛡️ DEFENSE VIEXIR REFLECT! Enemy projectile blocked and 100% damage reflected back to Anomaly!")
			var anomaly = get_tree().current_scene.get_node_or_null("Anomaly")
			if is_instance_valid(anomaly) and anomaly.has_method("take_damage"):
				anomaly.take_damage(base_damage)
			queue_free()
			return
	
	if body.has_method("take_damage"):
		body.take_damage(base_damage)
		
	if body.has_method("apply_poison"):
		body.apply_poison(1)
		
	queue_free()
