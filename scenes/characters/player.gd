extends CharacterBody2D

signal power_updated(percent: float)
signal ammo_changed(ammo_type: int)
signal sp_changed(current_sp: int, max_sp: int)
signal hp_changed(current_hp: int, max_hp: int)
signal poison_changed(poison_stack: int)

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var viexir_scene: PackedScene
var neutralize_viexir_scene: PackedScene = preload("res://scenes/objects/neutralize_viexir.tscn")

var throw_power: float = 0.0
var is_charging: bool = false
var is_active: bool = true

enum AmmoType { ATTACK, NEUTRALIZE }
var selected_ammo: AmmoType = AmmoType.ATTACK
var max_neutralize: int = 5 # GDD Bab 7.2: Maks 5 per battle

var attack_viexir_cost: int = 8 
var neutralize_viexir_cost: int = 10
var dodge_cost: int = 5 # GDD Bab 5.5: Dodge khusus 5 SP
var is_dodging: bool = false

@onready var throw_point: Marker2D = $ThrowPoint
@onready var power_bar: ProgressBar = $ProgressBar
@onready var trajectory_line: Line2D = $TrajectoryLine

@onready var ui_hp_bar: ProgressBar = get_node_or_null("../UI/HPBar")
@onready var ui_sp_label: Label = get_node_or_null("../UI/SPLabel")
@onready var ui_poison_label: Label = get_node_or_null("../UI/PoisonLabel")
@onready var ui_ammo_label: Label = get_node_or_null("../UI/AmmoLabel")

var position_at_turn_start: float = 0.0 
var gravity_value: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	# Initialize jump input (W key) if not already mapped
	if not InputMap.has_action("jump"):
		InputMap.add_action("jump")
		var key_w = InputEventKey.new()
		key_w.physical_keycode = KEY_W
		InputMap.action_add_event("jump", key_w)

	# Initialize UI and properties
	if is_instance_valid(power_bar):
		power_bar.max_value = 1200
		power_bar.value = 0
		power_bar.visible = false # Menggunakan Horizontal Power Ruler di UI bawah
	throw_point.rotation_degrees = -45 
	
	if is_instance_valid(ui_hp_bar):
		ui_hp_bar.max_value = Global.max_hp
		ui_hp_bar.value = Global.player_hp
	if is_instance_valid(ui_sp_label):
		ui_sp_label.text = "SP: %d / %d" % [Global.current_sp, Global.max_sp]
	update_ammo_ui()
	
	Global.is_in_battle = true
	hp_changed.emit(Global.player_hp, Global.max_hp)
	sp_changed.emit(Global.current_sp, Global.max_sp)
	poison_changed.emit(Global.poison_stack)
	ammo_changed.emit(int(selected_ammo))

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			select_ammo(AmmoType.ATTACK)
		elif event.keycode == KEY_3:
			select_ammo(AmmoType.NEUTRALIZE)
		elif event.keycode == KEY_Q:
			switch_ammo()
		elif event.keycode == KEY_SHIFT:
			perform_dodge()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			switch_ammo()

func select_ammo(ammo_type: AmmoType) -> void:
	selected_ammo = ammo_type
	update_ammo_ui()
	ammo_changed.emit(int(selected_ammo))
	AudioManager.play_click()
	print("Ammo selected: %s" % ("Attack Viexir" if selected_ammo == AmmoType.ATTACK else "Neutralize Viexir"))

func perform_dodge() -> void:
	if is_dodging:
		return
	if Global.current_sp < dodge_cost:
		print("Insufficient SP for Dodge! Requires %d SP, current: %d" % [dodge_cost, Global.current_sp])
		return
		
	Global.current_sp -= dodge_cost
	if is_instance_valid(ui_sp_label):
		ui_sp_label.text = "SP: %d / %d" % [Global.current_sp, Global.max_sp]
	sp_changed.emit(Global.current_sp, Global.max_sp)
		
	is_dodging = true
	AudioManager.play_dodge()
	var dir = Input.get_axis("ui_left", "ui_right")
	if dir == 0.0:
		dir = 1.0 if not $Sprite2D.flip_h else -1.0
	velocity.x = dir * 650.0
	
	# Visual feedback saat dodge
	var spr = get_node_or_null("Sprite2D")
	if is_instance_valid(spr):
		spr.modulate = Color(0.4, 0.8, 1.0, 0.5)
		var tween = create_tween()
		tween.tween_property(spr, "modulate", Color(1, 1, 1, 1), 0.35)
		
	print("💨 Player performed Dodge! (-5 SP, temporary invulnerability)")
	await get_tree().create_timer(0.35).timeout
	is_dodging = false

func switch_ammo() -> void:
	if selected_ammo == AmmoType.ATTACK:
		selected_ammo = AmmoType.NEUTRALIZE
	else:
		selected_ammo = AmmoType.ATTACK
	update_ammo_ui()
	ammo_changed.emit(int(selected_ammo))
	AudioManager.play_click()
	print("Ammo switched: %s" % ("Attack Viexir (8 SP)" if selected_ammo == AmmoType.ATTACK else "Neutralize Viexir (10 SP)"))

func update_ammo_ui() -> void:
	if is_instance_valid(ui_ammo_label):
		if selected_ammo == AmmoType.ATTACK:
			var count = Global.consumable_inventory.get("attack_viexir", 0)
			ui_ammo_label.text = "Viexir: Attack (%d) [Q/1: Switch]" % count
			ui_ammo_label.set("theme_override_colors/font_color", Color(1, 0.84, 0))
		else:
			var count = Global.consumable_inventory.get("neutralize_viexir", 0)
			ui_ammo_label.text = "Viexir: Neutralize (%d | Left: %d) [Q/3: Switch]" % [count, max_neutralize]
			ui_ammo_label.set("theme_override_colors/font_color", Color(0.2, 1, 0.4))

func _physics_process(delta: float) -> void:
	# 1. Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if not is_active:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return 
		
	# 2. Aiming
	if Input.is_action_pressed("ui_up"):
		throw_point.rotation_degrees -= 100 * delta 
	if Input.is_action_pressed("ui_down"):
		throw_point.rotation_degrees += 100 * delta 
		
	# 3. Movement & Jump (W key to Jump, Left/Right arrow to Move)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. Charging and Throwing
	if Input.is_action_just_pressed("ui_accept"):
		var cost = attack_viexir_cost if selected_ammo == AmmoType.ATTACK else neutralize_viexir_cost
		var item_key = "attack_viexir" if selected_ammo == AmmoType.ATTACK else "neutralize_viexir"
		var available = Global.consumable_inventory.get(item_key, 0)
		
		if selected_ammo == AmmoType.NEUTRALIZE and max_neutralize <= 0:
			print("Neutralize Viexir battle limit reached! (Max 5)")
		elif available <= 0:
			print("Out of %s Viexir! Craft at Basecamp." % ("Attack" if selected_ammo == AmmoType.ATTACK else "Neutralize"))
		elif Global.current_sp < cost:
			print("Insufficient SP! Requires %d SP, current: %d" % [cost, Global.current_sp])
		else:
			is_charging = true
			throw_power = 0.0
			power_updated.emit(0.0)
		
	if Input.is_action_pressed("ui_accept") and is_charging:
		throw_power += 1500 * delta
		throw_power = clamp(throw_power, 0, 1200)
		if is_instance_valid(power_bar):
			power_bar.value = throw_power
		var p_percent = (throw_power / 1200.0) * 100.0
		power_updated.emit(p_percent)
		update_trajectory()
		
	if Input.is_action_just_released("ui_accept") and is_charging:
		is_charging = false
		if is_instance_valid(power_bar):
			power_bar.value = 0
		power_updated.emit(0.0)
		trajectory_line.clear_points()
		throw_bottle()

	move_and_slide()

func throw_bottle() -> void:
	var cost = attack_viexir_cost if selected_ammo == AmmoType.ATTACK else neutralize_viexir_cost
	var item_key = "attack_viexir" if selected_ammo == AmmoType.ATTACK else "neutralize_viexir"
	var available = Global.consumable_inventory.get(item_key, 0)
	
	if selected_ammo == AmmoType.NEUTRALIZE and max_neutralize <= 0:
		print("Throw failed: Neutralize usage limit reached!")
		return
	if available <= 0:
		print("Throw failed: Out of Viexir!")
		return
		
	Global.use_item(item_key, 1)
	if selected_ammo == AmmoType.NEUTRALIZE:
		max_neutralize -= 1
		
	var scene_to_spawn = viexir_scene if selected_ammo == AmmoType.ATTACK else neutralize_viexir_scene
	if scene_to_spawn:
		var bottle = scene_to_spawn.instantiate()
		get_tree().current_scene.add_child(bottle)
		bottle.global_position = throw_point.global_position
		
		var throw_direction = Vector2.RIGHT.rotated(throw_point.rotation)
		bottle.linear_velocity = throw_direction * throw_power
		$"../MainCamera".target = bottle
		AudioManager.play_throw()
		
		Global.current_sp -= cost
		if is_instance_valid(ui_sp_label):
			ui_sp_label.text = "SP: %d / %d" % [Global.current_sp, Global.max_sp]
		sp_changed.emit(Global.current_sp, Global.max_sp)
		
		update_ammo_ui()
		print("Viexir thrown! Remaining SP: %d" % Global.current_sp)
		
		$"../TurnManager".end_player_turn()

func take_damage(amount: int, is_poison_damage: bool = false) -> void:
	if not is_poison_damage:
		if is_dodging:
			print("💨 Attack evaded with DODGE! (0 Damage)")
			return
		if Global.invisible_duration > 0:
			print("Attack missed! Player is Invisible!")
			return 
		
	Global.player_hp -= amount
	print("Player HP remaining: %d" % Global.player_hp)
	
	if is_instance_valid(ui_hp_bar):
		ui_hp_bar.value = Global.player_hp
	hp_changed.emit(Global.player_hp, Global.max_hp)
	
	if Global.player_hp <= 0:
		die()

func die() -> void:
	print("Player Died!")
	is_active = false
	
	var turn_manager = $"../TurnManager"
	if is_instance_valid(turn_manager):
		turn_manager.player_turn_timer.stop()
		turn_manager.enemy_delay_timer.stop()
	
	var game_over_screen = $"../GameOverScreen" 
	if is_instance_valid(game_over_screen):
		game_over_screen.show_game_over()
		
func apply_poison(amount: int) -> void:
	if Global.is_poison_protected:
		Global.is_poison_protected = false
		print("🛡️ Poison attack blocked by Neutralize Viexir protection!")
		return
		
	Global.poison_stack = min(5, Global.poison_stack + amount)
	if is_instance_valid(ui_poison_label):
		ui_poison_label.text = "Poison: %d/5" % Global.poison_stack
	poison_changed.emit(Global.poison_stack)
	print("Poisoned! Current stack: %d/5" % Global.poison_stack)

func evaluate_poison() -> void:
	if Global.poison_stack > 0:
		var distance_moved = abs(global_position.x - position_at_turn_start)
		
		if distance_moved < 10.0:
			Global.poison_stack = min(5, Global.poison_stack + 1)
			print("Player stationary! Poison increased to: %d/5" % Global.poison_stack)
		else:
			print("Player moved, poison stack remains: %d/5" % Global.poison_stack)
			
		# GDD Bab 6.3: Damage poison baru aktif pada 3 stack ke atas (1% Max HP per stack)
		if Global.poison_stack >= 3:
			var poison_damage = int(round(Global.max_hp * (Global.poison_stack * 0.01)))
			take_damage(poison_damage, true)
			print("Took poison damage: %d (Stack: %d/5)" % [poison_damage, Global.poison_stack])
		else:
			print("Poison stack (%d) below threshold 3, no damage taken." % Global.poison_stack)
			
		if is_instance_valid(ui_poison_label):
			ui_poison_label.text = "Poison: %d/5" % Global.poison_stack
		poison_changed.emit(Global.poison_stack)

func update_trajectory() -> void:
	trajectory_line.clear_points()
	if selected_ammo == AmmoType.ATTACK:
		trajectory_line.default_color = Color(1.0, 0.84, 0.0) # Emas
	else:
		trajectory_line.default_color = Color(0.2, 1.0, 0.4) # Hijau
	
	var max_points = 30 
	var time_step = 0.1 
	var start_pos = throw_point.global_position
	var initial_velocity = Vector2.RIGHT.rotated(throw_point.rotation) * throw_power
	
	for i in range(max_points):
		var t = i * time_step
		var point_pos = start_pos + (initial_velocity * t) + (Vector2(0, 1) * gravity_value * 0.5 * t * t)
		trajectory_line.add_point(trajectory_line.to_local(point_pos))
