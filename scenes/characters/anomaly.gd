extends CharacterBody2D

@export_enum("Common", "Rare", "Epic") var tier: String = "Common"

signal hp_changed(current_hp: int, max_hp: int)
signal debuff_changed(debuff_rounds: int)

var max_hp: int = 190
var hp: int = 190
var base_damage: int = 12
var damage: int = 12
var debuff_rounds: int = 0
var is_active: bool = false
var player_target: Node2D = null
var normal_color: Color = Color(1.0, 0.2, 0.2)
var hp_label: Label = null

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Attack Mechanics
var attack_range: float = 400.0
var enemy_bottle_scene: PackedScene = preload("res://scenes/objects/enemy_viexir.tscn")

# Anomaly Data & Weak Point (Head, Arms, Body)
var anomaly_name: String = "Common Anomaly (Toxic Slime)"
var anomaly_tier: String = "Common"
var weakness: String = "Attack Viexir"
var weak_point_part: String = "Head"

func _ready() -> void:
	if Global.next_battle_tier != "":
		tier = Global.next_battle_tier
		Global.next_battle_tier = "Common"
		
	match tier:
		"Common":
			anomaly_name = "Common Anomaly (Toxic Slime)"
			anomaly_tier = "Common"
			max_hp = 190
			hp = 190
			base_damage = 12
			damage = 12
			weakness = "Attack Viexir"
			normal_color = Color(1.0, 0.2, 0.2)
		"Rare":
			anomaly_name = "Rare Anomaly (Corrupted Beast)"
			anomaly_tier = "Rare"
			max_hp = 340
			hp = 340
			base_damage = 20
			damage = 20
			weakness = "Attack Viexir + Neutralize Viexir"
			normal_color = Color(0.3, 0.6, 1.0)
		"Epic":
			anomaly_name = "Epic Anomaly (Void Goliath)"
			anomaly_tier = "Epic"
			max_hp = 500
			hp = 500
			base_damage = 25
			damage = 25
			weakness = "Attack Viexir + Neutralize Viexir + Defense Viexir"
			normal_color = Color(0.9, 0.4, 0.1)
			
	var spr = get_node_or_null("Sprite2D")
	if is_instance_valid(spr):
		spr.modulate = normal_color
		
	# Randomize Weak Point (Head, Arms, Body) for all Anomaly tiers
	var parts = ["Head", "Arms", "Body"]
	weak_point_part = parts.pick_random()
	print("[%s] Randomized weak point: %s" % [anomaly_name, weak_point_part])
		
	_setup_hp_ui()
	hp_changed.emit(hp, max_hp)

func _setup_hp_ui() -> void:
	hp_label = Label.new()
	hp_label.position = Vector2(-75, -95)
	hp_label.size = Vector2(150, 24)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.text = "HP: %d / %d" % [hp, max_hp]
	hp_label.set("theme_override_colors/font_color", Color(1, 0.35, 0.35))
	add_child(hp_label)

func _update_hp_ui() -> void:
	if is_instance_valid(hp_label):
		hp_label.text = "HP: %d / %d" % [max(0, hp), max_hp]
	hp_changed.emit(max(0, hp), max_hp)

func take_damage_hit(amount: int, hit_world_pos: Vector2) -> void:
	var local_y: float = hit_world_pos.y - global_position.y
	var local_x: float = abs(hit_world_pos.x - global_position.x)
	
	var hit_part: String = "Body"
	if local_y < -18.0:
		hit_part = "Head"
	elif local_x > 28.0:
		hit_part = "Arms"
	else:
		hit_part = "Body"
		
	var is_crit: bool = (hit_part == weak_point_part)
	var final_damage: int = amount
	
	if is_crit:
		final_damage = int(amount * 1.5)
		_show_floating_text("CRITICAL! %s (-%d)" % [hit_part, final_damage], Color(1.0, 0.85, 0.1))
		print("💥 CRITICAL HIT! Weak point (%s) struck! Damage 1.5x: %d" % [hit_part, final_damage])
	else:
		_show_floating_text("%s (-%d)" % [hit_part, final_damage], Color(1.0, 0.4, 0.4))
		print("Hit part %s (Not weak point %s). Damage: %d" % [hit_part, weak_point_part, final_damage])
		
	take_damage(final_damage)

func _show_floating_text(text: String, color: Color) -> void:
	var f_label = Label.new()
	f_label.text = text
	f_label.position = Vector2(-80, -125)
	f_label.size = Vector2(160, 30)
	f_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	f_label.set("theme_override_colors/font_color", color)
	f_label.set("theme_override_font_sizes/font_size", 16)
	f_label.z_index = 50
	add_child(f_label)
	
	var tween = create_tween()
	tween.parallel().tween_property(f_label, "position:y", f_label.position.y - 40, 0.8)
	tween.parallel().tween_property(f_label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(f_label.queue_free)

func get_anomaly_intel() -> Dictionary:
	return {
		"name": anomaly_name,
		"tier": anomaly_tier,
		"weakness": weakness,
		"weak_point": weak_point_part,
		"hp": hp,
		"max_hp": max_hp,
		"damage": damage,
		"debuff_rounds": debuff_rounds
	}

func take_damage(amount: int) -> void:
	hp -= amount
	_update_hp_ui()
	print("%s took damage! Remaining HP: %d" % [anomaly_name, hp])
	
	if hp <= 0:
		die()

func die() -> void:
	print("%s Destroyed!" % anomaly_name)
	Global.enemies_defeated += 1
	
	var turn_manager = $"../TurnManager"
	if is_instance_valid(turn_manager):
		turn_manager.player_turn_timer.stop()
		turn_manager.enemy_delay_timer.stop()
	
	# Loot Drop & EXP Reward (GDD Bab 1 Halaman 3, Bab 11, Bab 12)
	var exp_gained: int = 20
	var coins_gained: int = 10
	var drop_summary: String = ""
	
	match tier:
		"Common":
			exp_gained = 20
			coins_gained = 10
			Global.add_item("red_crystal", 1)
			drop_summary = "+1 Red Crystal, +%d Coins" % coins_gained
			if randf() <= 0.3:
				Global.add_item("green_crystal", 1)
				drop_summary += ", +1 Green Crystal (Bonus 30%)"
		"Rare":
			exp_gained = 40
			coins_gained = 25
			Global.add_item("blue_crystal", 1)
			drop_summary = "+1 Blue Crystal, +%d Coins" % coins_gained
			if randf() <= 0.5:
				Global.add_item("green_crystal", 1)
				drop_summary += ", +1 Green Crystal (Bonus 50%)"
		"Epic":
			exp_gained = 70
			coins_gained = 50
			Global.add_item("gold_crystal", 1)
			drop_summary = "+1 Gold Crystal, +%d Coins" % coins_gained
			if randf() <= 0.5:
				Global.add_item("blue_crystal", 1)
				drop_summary += ", +1 Blue Crystal (Bonus 50%)"
	
	Global.add_coins(coins_gained)
	Global.gain_exp(exp_gained)
	print("Loot Drop: %s | +%d EXP" % [drop_summary, exp_gained])
	
	var victory_screen = $"../VictoryScreen"
	if is_instance_valid(victory_screen):
		victory_screen.show_victory(exp_gained, drop_summary)
		
	queue_free()
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_active and is_instance_valid(player_target):
		var distance_to_player: float = global_position.distance_to(player_target.global_position)
		var direction: float = sign(player_target.global_position.x - global_position.x)
		
		if distance_to_player <= attack_range:
			is_active = false 
			velocity.x = 0
			
			if distance_to_player < 100.0:
				melee_attack()
			else:
				throw_bottle(direction)
		else:
			velocity.x = direction * 100 
			
	else:
		velocity.x = move_toward(velocity.x, 0, 100) 
		
	move_and_slide()

# Combat Actions
func apply_neutralize(hit_world_pos: Vector2 = Vector2.INF) -> void:
	print("Neutralize Viexir hit Anomaly!")
	debuff_rounds = 2
	damage = int(base_damage * 0.6) # ATK berkurang 40%
	$Sprite2D.modulate = Color(0.2, 1.2, 0.4, 1.0) # Aura hijau
	
	# Bersihkan Poison Pemain & berikan perlindungan 1 kali
	Global.poison_stack = 0
	Global.is_poison_protected = true
	var player = get_tree().current_scene.get_node_or_null("Player")
	if is_instance_valid(player) and is_instance_valid(player.ui_poison_label):
		player.ui_poison_label.text = "Poison: 0/5"
	debuff_changed.emit(debuff_rounds)
	_show_floating_text("DEBUFF -40% ATK!", Color(0.2, 1.0, 0.5))
	print("Anomaly debuffed! ATK: %d (reduced by 40%% for 2 rounds) | Player poison cleansed!" % damage)

func update_debuff() -> void:
	if debuff_rounds > 0:
		debuff_rounds -= 1
		debuff_changed.emit(debuff_rounds)
		if debuff_rounds == 0:
			damage = base_damage
			var spr = get_node_or_null("Sprite2D")
			if is_instance_valid(spr):
				spr.modulate = normal_color
			print("Neutralize effect on Anomaly expired. ATK restored.")

func melee_attack() -> void:
	print("Anomaly uses Melee Attack!")
	
	# Check Viexir Defense (Reflect)
	if Global.is_reflecting_shield:
		Global.is_reflecting_shield = false
		print("🛡️ DEFENSE VIEXIR REFLECT! Melee attack blocked & 100% reflected back to Anomaly!")
		take_damage(damage)
	else:
		if is_instance_valid(player_target) and player_target.has_method("take_damage"):
			player_target.take_damage(damage)
		if is_instance_valid(player_target) and player_target.has_method("apply_poison"):
			player_target.apply_poison(1) 
	
	await get_tree().create_timer(0.5).timeout
	if hp > 0:
		var tm = get_node_or_null("../TurnManager")
		if is_instance_valid(tm):
			tm.start_player_turn()

func throw_bottle(direction_x: float) -> void:
	var bullet = enemy_bottle_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + Vector2(direction_x * 40, -60) 
	
	var force_x: float = 400.0 * direction_x 
	var force_y: float = -350.0 
	
	# Wind Potion Logic
	if Global.wind_duration > 0:
		print("WHOOSH! Enemy projectile blown away by wind!")
		force_x = -force_x
		force_y = -600.0 
		
	bullet.apply_impulse(Vector2(force_x, force_y))
	
	await get_tree().create_timer(1.5).timeout
	if hp > 0:
		var tm = get_node_or_null("../TurnManager")
		if is_instance_valid(tm):
			tm.start_player_turn()

# Turn Manager Hook
func start_turn(target: Node2D) -> void:
	player_target = target
	is_active = true
	print("Anomaly turn started!")
	
	await get_tree().create_timer(4.0).timeout
	if is_active and hp > 0: 
		is_active = false
		velocity.x = 0
		print("Anomaly turn timed out.")
		var tm = get_node_or_null("../TurnManager")
		if is_instance_valid(tm):
			tm.start_player_turn()
