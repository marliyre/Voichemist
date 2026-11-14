extends Camera2D

var target: Node2D = null
var smooth_speed: float = 5.0

func _process(delta: float) -> void:
	if is_instance_valid(target):
		global_position = global_position.lerp(target.global_position, smooth_speed * delta)
