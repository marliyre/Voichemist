extends RigidBody2D

@onready var explosion_particles: CPUParticles2D = $CPUParticles2D
@onready var bottle_sprite: Sprite2D = $Sprite2D

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		return
		
	# Cek apakah Anomali
	if body.has_method("apply_neutralize"):
		body.apply_neutralize(global_position)
	elif body.has_method("take_damage_hit"):
		body.take_damage_hit(20, global_position)
	elif body.has_method("take_damage"):
		body.take_damage(20)
	
	AudioManager.play_hit()
	
	# Freeze physics on impact
	linear_velocity = Vector2.ZERO
	gravity_scale = 0.0
	set_deferred("freeze", true)
	
	if is_instance_valid(bottle_sprite):
		bottle_sprite.hide()
	
	if is_instance_valid(explosion_particles):
		explosion_particles.emitting = true
	
	await get_tree().create_timer(0.5).timeout
	queue_free()
