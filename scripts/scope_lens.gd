extends Control

var pulse_time: float = 0.0

func _process(delta: float) -> void:
	if visible:
		pulse_time += delta * 2.0
		queue_redraw()

func _draw() -> void:
	var center = size * 0.5
	var radius = min(center.x, center.y) - 12.0
	if radius <= 10.0:
		return
		
	# Outer Dark Brass / Metal Ring
	draw_circle(center, radius + 8.0, Color(0.12, 0.10, 0.08, 0.95))
	draw_arc(center, radius + 4.0, 0, TAU, 64, Color(0.85, 0.65, 0.22, 1.0), 5.0)
	draw_arc(center, radius + 7.0, 0, TAU, 64, Color(0.45, 0.35, 0.15, 1.0), 2.0)
	
	# Inner Scope Lens Glow
	draw_circle(center, radius, Color(0.04, 0.14, 0.18, 0.90))
	
	# Concentric Radar / Targeting Rings
	draw_arc(center, radius * 0.8, 0, TAU, 48, Color(0.18, 0.8, 0.9, 0.5), 1.5)
	draw_arc(center, radius * 0.55, 0, TAU, 40, Color(0.18, 0.8, 0.9, 0.7), 2.0)
	draw_arc(center, radius * 0.3, 0, TAU, 32, Color(0.9, 0.3, 0.3, 0.8), 2.0)
	
	# Pulsing Scanner Ring
	var pulse_radius = radius * (0.2 + (sin(pulse_time) * 0.5 + 0.5) * 0.6)
	draw_arc(center, pulse_radius, 0, TAU, 36, Color(0.2, 1.0, 0.6, 0.4), 1.5)
	
	# Crosshairs (+ and ticks)
	var cross_color = Color(0.2, 0.9, 0.95, 0.75)
	draw_line(Vector2(center.x - radius, center.y), Vector2(center.x + radius, center.y), cross_color, 1.5)
	draw_line(Vector2(center.x, center.y - radius), Vector2(center.x, center.y + radius), cross_color, 1.5)
	
	# Distance Ticks on Crosshair
	for i in [-0.7, -0.4, 0.4, 0.7]:
		var tx = center.x + radius * i
		var ty = center.y + radius * i
		draw_line(Vector2(tx, center.y - 4), Vector2(tx, center.y + 4), cross_color, 1.5)
		draw_line(Vector2(center.x - 4, ty), Vector2(center.x + 4, ty), cross_color, 1.5)
		
	# Red Center Reticle Pip
	draw_circle(center, 3.5, Color(1.0, 0.25, 0.25, 1.0))
