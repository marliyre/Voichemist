extends HBoxContainer

signal scope_requested(intel_data: Dictionary)
signal battle_buff_updated()

# Battle Limits (GDD v3.4)
var max_neutralize: int = 5
var max_tahan: int = 3
var max_heal: int = 2
var max_stamina: int = 2
var max_wind: int = 1
var max_invisible: int = 1

@export var player_node: NodePath
@export var enemy_node: NodePath

# 8 Hotbar Slot Buttons
@onready var slot1: Button = get_node_or_null("Slot1")
@onready var slot2: Button = get_node_or_null("Slot2")
@onready var slot3: Button = get_node_or_null("Slot3")
@onready var slot4: Button = get_node_or_null("Slot4")
@onready var slot5: Button = get_node_or_null("Slot5")
@onready var slot6: Button = get_node_or_null("Slot6")
@onready var slot7: Button = get_node_or_null("Slot7")
@onready var slot8: Button = get_node_or_null("Slot8")

var active_ammo_slot: int = 1 # 1: Attack Viexir, 3: Neutralize Viexir

func _ready() -> void:
	_connect_slots()
	update_ui()
	
	var player = _get_player()
	if is_instance_valid(player) and player.has_signal("ammo_changed"):
		player.ammo_changed.connect(_on_player_ammo_changed)

func _connect_slots() -> void:
	if is_instance_valid(slot1):
		slot1.pressed.connect(_on_slot1_pressed)
	if is_instance_valid(slot2):
		slot2.pressed.connect(_on_slot2_pressed)
	if is_instance_valid(slot3):
		slot3.pressed.connect(_on_slot3_pressed)
	if is_instance_valid(slot4):
		slot4.pressed.connect(_on_slot4_pressed)
	if is_instance_valid(slot5):
		slot5.pressed.connect(_on_slot5_pressed)
	if is_instance_valid(slot6):
		slot6.pressed.connect(_on_slot6_pressed)
	if is_instance_valid(slot7):
		slot7.pressed.connect(_on_slot7_pressed)
	if is_instance_valid(slot8):
		slot8.pressed.connect(_on_slot8_pressed)

func _unhandled_input(event: InputEvent) -> void:
	var player = _get_player()
	if not is_instance_valid(player) or not player.is_active:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_on_slot1_pressed()
			KEY_2:
				_on_slot2_pressed()
			KEY_3:
				_on_slot3_pressed()
			KEY_4:
				_on_slot4_pressed()
			KEY_5:
				_on_slot5_pressed()
			KEY_6:
				_on_slot6_pressed()
			KEY_7:
				_on_slot7_pressed()
			KEY_8:
				_on_slot8_pressed()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Toggle between Slot 1 (Attack) and Slot 3 (Neutralize)
			if active_ammo_slot == 1:
				_on_slot3_pressed()
			else:
				_on_slot1_pressed()

func _on_player_ammo_changed(ammo_type: int) -> void:
	active_ammo_slot = 1 if ammo_type == 0 else 3
	update_ui()

# Slot 1: Attack Viexir (8 SP / throw)
func _on_slot1_pressed() -> void:
	var player = _get_player()
	if is_instance_valid(player):
		player.select_ammo(0) # AmmoType.ATTACK
		active_ammo_slot = 1
		update_ui()

# Slot 2: Defense Viexir (Reflect Shield 100%, 10 SP, Limit 3)
func _on_slot2_pressed() -> void:
	if Global.is_reflecting_shield:
		print("🛡️ Defense Viexir is already active!")
		return
	if max_tahan <= 0:
		print("Defense Viexir limit reached for this battle! (Max 3)")
		return
	if Global.current_sp < 10:
		print("Insufficient SP for Defense Viexir! Requires 10 SP, current: %d" % Global.current_sp)
		return
	if not Global.use_item("defense_viexir", 1):
		print("Defense Viexir out of stock in inventory!")
		return
		
	max_tahan -= 1
	Global.current_sp -= 10
	Global.is_reflecting_shield = true
	AudioManager.play_coin()
	print("🛡️ Defense Viexir active! Next enemy attack will be reflected 100% (-10 SP)")
	
	var player = _get_player()
	if is_instance_valid(player):
		player.sp_changed.emit(Global.current_sp, Global.max_sp)
	battle_buff_updated.emit()
	update_ui()

# Slot 3: Neutralize Viexir (10 SP / throw, Debuff 40% ATK, Limit 5)
func _on_slot3_pressed() -> void:
	var player = _get_player()
	if is_instance_valid(player):
		player.select_ammo(1) # AmmoType.NEUTRALIZE
		active_ammo_slot = 3
		update_ui()

# Slot 4: Heal Potion (Restore 30% Max HP, Limit 2)
func _on_slot4_pressed() -> void:
	if max_heal <= 0:
		print("Health Potion limit reached for this battle! (Max 2)")
		return
	if Global.player_hp >= Global.max_hp:
		print("HP is already full!")
		return
	if not Global.use_item("heal_potion", 1):
		print("Health Potion out of stock in inventory!")
		return
		
	max_heal -= 1
	var heal_amount = int(round(Global.max_hp * 0.3))
	Global.player_hp = min(Global.max_hp, Global.player_hp + heal_amount)
	AudioManager.play_leaf()
	print("💚 Health Potion used! Restored +%d HP. Current HP: %d/%d" % [heal_amount, Global.player_hp, Global.max_hp])
	
	var player = _get_player()
	if is_instance_valid(player):
		player.hp_changed.emit(Global.player_hp, Global.max_hp)
	battle_buff_updated.emit()
	update_ui()

# Slot 5: Stamina Potion (+30 SP, Limit 2)
func _on_slot5_pressed() -> void:
	if max_stamina <= 0:
		print("Stamina Potion limit reached for this battle! (Max 2)")
		return
	if Global.current_sp >= Global.max_sp:
		print("SP is already full!")
		return
	if not Global.use_item("stamina_potion", 1):
		print("Stamina Potion out of stock in inventory!")
		return
		
	max_stamina -= 1
	Global.current_sp = min(Global.max_sp, Global.current_sp + 30)
	AudioManager.play_leaf()
	print("⚡ Stamina Potion used! Restored +30 SP. Current SP: %d/%d" % [Global.current_sp, Global.max_sp])
	
	var player = _get_player()
	if is_instance_valid(player):
		player.sp_changed.emit(Global.current_sp, Global.max_sp)
	battle_buff_updated.emit()
	update_ui()

# Slot 6: Wind Potion (Deflect enemy bottle attacks for 2 turns, Limit 1)
func _on_slot6_pressed() -> void:
	if max_wind <= 0:
		print("Wind Potion limit reached for this battle! (Max 1)")
		return
	if not Global.use_item("wind_potion", 1):
		print("Wind Potion out of stock in inventory!")
		return
		
	max_wind -= 1
	Global.wind_duration = 2
	AudioManager.play_throw()
	print("💨 Wind Potion active! Enemy projectiles will be deflected for 2 rounds!")
	battle_buff_updated.emit()
	update_ui()

# Slot 7: Invisible Potion (Invulnerable for 2 turns, Limit 1)
func _on_slot7_pressed() -> void:
	if max_invisible <= 0:
		print("Invisibility Potion limit reached for this battle! (Max 1)")
		return
	if not Global.use_item("invisible_potion", 1):
		print("Invisibility Potion out of stock in inventory!")
		return
		
	max_invisible -= 1
	Global.invisible_duration = 2
	AudioManager.play_dodge()
	print("👻 Invisibility Potion active! Invulnerable to attacks for 2 rounds!")
	battle_buff_updated.emit()
	update_ui()

# Slot 8: Spiral Scope (Scan Anomaly weak point & weakness, 5 SP)
func _on_slot8_pressed() -> void:
	if Global.current_sp < 5:
		print("Insufficient SP for Spiral Scope! (Requires 5 SP)")
		return
	var count_scope = Global.consumable_inventory.get("spiral_scope", 0)
	if count_scope <= 0:
		print("Spiral Scope out of stock in inventory!")
		return
	if not Global.use_item("spiral_scope", 1):
		return
		
	Global.current_sp -= 5
	AudioManager.play_click()
	print("🔍 Spiral Scope used! (-5 SP, -1 Scope)")
	
	var player = _get_player()
	if is_instance_valid(player):
		player.sp_changed.emit(Global.current_sp, Global.max_sp)
		
	var enemy = _get_enemy()
	var intel: Dictionary = {}
	if is_instance_valid(enemy) and enemy.has_method("get_anomaly_intel"):
		intel = enemy.get_anomaly_intel()
	else:
		intel = {
			"name": "Anomaly",
			"tier": "Common",
			"weakness": "Attack Viexir",
			"weak_point": "Head",
			"hp": 100,
			"max_hp": 100
		}
		
	scope_requested.emit(intel)
	update_ui()

# UI Refresh
func update_ui() -> void:
	_update_slot(slot1, "1\nAttack", Global.consumable_inventory.get("attack_viexir", 0), -1, active_ammo_slot == 1)
	_update_slot(slot2, "2\nDefense", Global.consumable_inventory.get("defense_viexir", 0), max_tahan, false, Global.is_reflecting_shield)
	_update_slot(slot3, "3\nNeutral", Global.consumable_inventory.get("neutralize_viexir", 0), max_neutralize, active_ammo_slot == 3)
	_update_slot(slot4, "4\nHeal", Global.consumable_inventory.get("heal_potion", 0), max_heal, false, Global.player_hp >= Global.max_hp)
	_update_slot(slot5, "5\nStamina", Global.consumable_inventory.get("stamina_potion", 0), max_stamina, false, Global.current_sp >= Global.max_sp)
	_update_slot(slot6, "6\nWind", Global.consumable_inventory.get("wind_potion", 0), max_wind, false, Global.wind_duration > 0)
	_update_slot(slot7, "7\nInvis", Global.consumable_inventory.get("invisible_potion", 0), max_invisible, false, Global.invisible_duration > 0)
	_update_slot(slot8, "8\nScope", Global.consumable_inventory.get("spiral_scope", 0), -1, false, Global.current_sp < 5)

func _update_slot(btn: Button, title: String, count: int, limit: int, is_active_ammo: bool, is_soft_disabled: bool = false) -> void:
	if not is_instance_valid(btn):
		return
		
	var badge_text = "x%d" % count
	if limit >= 0:
		badge_text += "(%d)" % limit
		
	btn.text = "%s\n%s" % [title, badge_text]
	
	# Visual highlight for active ammo or disabled
	var is_out_of_stock = (count <= 0) or (limit == 0)
	btn.disabled = is_out_of_stock or is_soft_disabled
	
	if is_active_ammo:
		btn.modulate = Color(1.2, 1.1, 0.4, 1.0) # Golden glow
	elif btn.disabled:
		btn.modulate = Color(0.55, 0.55, 0.55, 0.7) # Dimmed
	else:
		btn.modulate = Color(1.0, 1.0, 1.0, 1.0) # Normal

func _get_player() -> Node2D:
	if not player_node.is_empty():
		return get_node_or_null(player_node)
	return get_tree().current_scene.get_node_or_null("Player")

func _get_enemy() -> Node2D:
	if not enemy_node.is_empty():
		return get_node_or_null(enemy_node)
	return get_tree().current_scene.get_node_or_null("Anomaly")
