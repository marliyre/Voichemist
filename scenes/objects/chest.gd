extends Area2D

func _on_body_entered(_body: Node) -> void:
	collect_loot()

func collect_loot() -> void:
	var col = get_node_or_null("CollisionShape2D")
	if is_instance_valid(col):
		col.set_deferred("disabled", true)
	
	print("Chest opened!")
	
	# Sesuai GDD Bab 2.3 & Bab 12: Peti memberikan Batu, Besi, Kulit, dan Koin (tidak memberikan Azer/Kristal)
	Global.add_item("stone", 3)
	Global.add_item("iron", 2)
	Global.add_item("leather", 2)
	Global.add_coins(15)
	
	# Sesuai GDD Halaman 3: Membuka Chest = 5 EXP
	Global.gain_exp(5)
	AudioManager.play_coin()
	
	print("Chest loot obtained: 3 Stone, 2 Iron, 2 Leather, 15 Coins | +5 EXP")
	_show_floating_text("+15 Coins, +3 Stone, +2 Iron, +2 Leather (+5 EXP)")
	
	var spr = get_node_or_null("Sprite2D")
	if is_instance_valid(spr):
		spr.modulate = Color(0.5, 0.5, 0.5, 0.5)
	await get_tree().create_timer(0.7).timeout
	queue_free()

func _show_floating_text(text: String) -> void:
	var lbl = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.set("theme_override_colors/font_color", Color(1.0, 0.85, 0.2))
	lbl.set("theme_override_font_sizes/font_size", 10)
	lbl.z_index = 50
	lbl.position = Vector2(-120, -32)
	lbl.size = Vector2(240, 20)
	add_child(lbl)
	
	var tween = create_tween()
	tween.parallel().tween_property(lbl, "position:y", lbl.position.y - 25, 0.7)
	tween.parallel().tween_property(lbl, "modulate:a", 0.0, 0.7)
	tween.tween_callback(lbl.queue_free)
