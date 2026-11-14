extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var anomaly: CharacterBody2D = $Anomaly
@onready var turn_manager: Node = $TurnManager
@onready var main_camera: Camera2D = $MainCamera

# Top HUD References
@onready var top_hud: Control = $UI/TopHUD
@onready var player_hp_bar: ProgressBar = $UI/TopHUD/PlayerStatus/Bars/HPContainer/HPBar
@onready var player_hp_label: Label = $UI/TopHUD/PlayerStatus/Bars/HPContainer/HPBar/Label
@onready var player_sp_bar: ProgressBar = $UI/TopHUD/PlayerStatus/Bars/SPContainer/SPBar
@onready var player_sp_label: Label = $UI/TopHUD/PlayerStatus/Bars/SPContainer/SPBar/Label
@onready var player_name_label: Label = $UI/TopHUD/PlayerStatus/Bars/PlayerNameLabel

@onready var badge_poison: Label = $UI/TopHUD/PlayerStatus/Bars/Buffs/BadgePoison
@onready var badge_shield: Label = $UI/TopHUD/PlayerStatus/Bars/Buffs/BadgeShield
@onready var badge_wind: Label = $UI/TopHUD/PlayerStatus/Bars/Buffs/BadgeWind
@onready var badge_invisible: Label = $UI/TopHUD/PlayerStatus/Bars/Buffs/BadgeInvisible

@onready var turn_label: Label = $UI/TopHUD/CenterGem/TurnLabel
@onready var timer_label: Label = $UI/TopHUD/CenterGem/GemOrb/TimerLabel
@onready var btn_pause: Button = $UI/TopHUD/BtnPause

@onready var enemy_name_label: Label = $UI/TopHUD/EnemyStatus/Bars/EnemyNameLabel
@onready var enemy_hp_bar: ProgressBar = $UI/TopHUD/EnemyStatus/Bars/HPContainer/HPBar
@onready var enemy_hp_label: Label = $UI/TopHUD/EnemyStatus/Bars/HPContainer/HPBar/Label
@onready var badge_netral: Label = $UI/TopHUD/EnemyStatus/Bars/Debuffs/BadgeNetral

# Bottom HUD References
@onready var bottom_hud: Control = $UI/BottomHUD
@onready var btn_kabur: Button = $UI/BottomHUD/BtnKabur
@onready var power_bar: ProgressBar = $UI/BottomHUD/ActionPanel/HBox/PowerRuler/RulerBar/PowerBar
@onready var power_needle: Control = $UI/BottomHUD/ActionPanel/HBox/PowerRuler/RulerBar/Needle
@onready var power_value_label: Label = $UI/BottomHUD/ActionPanel/HBox/PowerRuler/PowerValue
@onready var sabuk_alkimia: HBoxContainer = $UI/BottomHUD/ActionPanel/HBox/SabukAlkimia/Slots

# Modals
@onready var spiral_scope_modal: Control = $UI/SpiralScopeModal
@onready var scope_target_label: Label = $UI/SpiralScopeModal/Card/HBox/Info/TargetLabel
@onready var scope_tier_label: Label = $UI/SpiralScopeModal/Card/HBox/Info/TierLabel
@onready var scope_weakness_label: Label = $UI/SpiralScopeModal/Card/HBox/Info/WeaknessLabel
@onready var scope_weakpoint_label: Label = $UI/SpiralScopeModal/Card/HBox/Info/WeakPointPanel/WeakPointLabel
@onready var btn_close_scope: Button = $UI/SpiralScopeModal/Card/HBox/Info/BtnCloseScope

@onready var escape_modal: Control = $UI/EscapeModal
@onready var btn_confirm_escape: Button = $UI/EscapeModal/Card/HBoxButtons/BtnConfirmEscape
@onready var btn_cancel_escape: Button = $UI/EscapeModal/Card/HBoxButtons/BtnCancelEscape

@onready var pause_modal: Control = $UI/PauseModal
@onready var btn_resume: Button = $UI/PauseModal/Card/VBox/BtnResume
@onready var btn_to_basecamp: Button = $UI/PauseModal/Card/VBox/BtnToBasecamp
@onready var btn_to_menu: Button = $UI/PauseModal/Card/VBox/BtnToMenu

var initial_needle_x: float = 0.0

func _ready() -> void:
	Global.is_in_battle = true
	_connect_signals()
	_init_ui()
	_update_buffs_ui()

func _connect_signals() -> void:
	# Player Signals
	if is_instance_valid(player):
		player.power_updated.connect(_on_power_updated)
		player.hp_changed.connect(_on_player_hp_changed)
		player.sp_changed.connect(_on_player_sp_changed)
		player.poison_changed.connect(_on_player_poison_changed)

	# Anomaly Signals
	if is_instance_valid(anomaly):
		anomaly.hp_changed.connect(_on_anomaly_hp_changed)
		anomaly.debuff_changed.connect(_on_anomaly_debuff_changed)

	# TurnManager Signals
	if is_instance_valid(turn_manager):
		turn_manager.timer_ticked.connect(_on_timer_ticked)
		turn_manager.turn_changed.connect(_on_turn_changed)

	# Sabuk Alkimia Signals
	if is_instance_valid(sabuk_alkimia):
		sabuk_alkimia.scope_requested.connect(open_scope_modal)
		sabuk_alkimia.battle_buff_updated.connect(_update_buffs_ui)

	# Bottom Buttons
	if is_instance_valid(btn_kabur):
		btn_kabur.pressed.connect(_on_btn_kabur_pressed)
	if is_instance_valid(btn_pause):
		btn_pause.pressed.connect(_toggle_pause)

	# Scope Modal
	if is_instance_valid(btn_close_scope):
		btn_close_scope.pressed.connect(close_scope_modal)

	# Escape Modal
	if is_instance_valid(btn_confirm_escape):
		btn_confirm_escape.pressed.connect(_on_confirm_escape)
	if is_instance_valid(btn_cancel_escape):
		btn_cancel_escape.pressed.connect(close_escape_modal)

	# Pause Modal
	if is_instance_valid(btn_resume):
		btn_resume.pressed.connect(_toggle_pause)
	if is_instance_valid(btn_to_basecamp):
		btn_to_basecamp.pressed.connect(_on_return_basecamp)
	if is_instance_valid(btn_to_menu):
		btn_to_menu.pressed.connect(_on_return_basecamp)

func _init_ui() -> void:
	# Initial Player Status
	if is_instance_valid(player_name_label):
		player_name_label.text = "PLAYER (Lv. %d)" % Global.player_level
	_on_player_hp_changed(Global.player_hp, Global.max_hp)
	_on_player_sp_changed(Global.current_sp, Global.max_sp)
	_on_player_poison_changed(Global.poison_stack)

	# Initial Enemy Status
	if is_instance_valid(anomaly):
		if is_instance_valid(enemy_name_label):
			enemy_name_label.text = "%s [%s]" % [anomaly.anomaly_name, anomaly.anomaly_tier]
		_on_anomaly_hp_changed(anomaly.hp, anomaly.max_hp)
		_on_anomaly_debuff_changed(anomaly.debuff_rounds)

	# Initial Power Ruler
	if is_instance_valid(power_needle):
		initial_needle_x = power_needle.position.x
	_on_power_updated(0.0)

	# Hide Modals
	if is_instance_valid(spiral_scope_modal):
		spiral_scope_modal.visible = false
	if is_instance_valid(escape_modal):
		escape_modal.visible = false
	if is_instance_valid(pause_modal):
		pause_modal.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if is_instance_valid(spiral_scope_modal) and spiral_scope_modal.visible:
				close_scope_modal()
			elif is_instance_valid(escape_modal) and escape_modal.visible:
				close_escape_modal()
			else:
				_toggle_pause()

# --- Top HUD Handlers ---
func _on_player_hp_changed(cur_hp: int, max_hp: int) -> void:
	if is_instance_valid(player_hp_bar):
		player_hp_bar.max_value = max_hp
		player_hp_bar.value = cur_hp
	if is_instance_valid(player_hp_label):
		player_hp_label.text = "%d / %d" % [cur_hp, max_hp]

func _on_player_sp_changed(cur_sp: int, max_sp: int) -> void:
	if is_instance_valid(player_sp_bar):
		player_sp_bar.max_value = max_sp
		player_sp_bar.value = cur_sp
	if is_instance_valid(player_sp_label):
		player_sp_label.text = "%d / %d" % [cur_sp, max_sp]

func _on_player_poison_changed(stack: int) -> void:
	if is_instance_valid(badge_poison):
		badge_poison.visible = (stack > 0)
		badge_poison.text = "☠ Poison x%d" % stack

func _on_anomaly_hp_changed(cur_hp: int, max_hp: int) -> void:
	if is_instance_valid(enemy_hp_bar):
		enemy_hp_bar.max_value = max_hp
		enemy_hp_bar.value = cur_hp
	if is_instance_valid(enemy_hp_label):
		enemy_hp_label.text = "%d / %d" % [cur_hp, max_hp]

func _on_anomaly_debuff_changed(rounds: int) -> void:
	if is_instance_valid(badge_netral):
		badge_netral.visible = (rounds > 0)
		badge_netral.text = "🧪 Neutralized (-40%% ATK: %d R)" % rounds

func _update_buffs_ui() -> void:
	if is_instance_valid(badge_shield):
		badge_shield.visible = Global.is_reflecting_shield
	if is_instance_valid(badge_wind):
		badge_wind.visible = (Global.wind_duration > 0)
		badge_wind.text = "💨 Wind (%d R)" % Global.wind_duration
	if is_instance_valid(badge_invisible):
		badge_invisible.visible = (Global.invisible_duration > 0)
		badge_invisible.text = "👻 Invisible (%d R)" % Global.invisible_duration

func _on_timer_ticked(seconds_left: int) -> void:
	if is_instance_valid(timer_label):
		timer_label.text = str(seconds_left)

func _on_turn_changed(is_player: bool) -> void:
	if is_instance_valid(turn_label):
		if is_player:
			turn_label.text = "PLAYER TURN"
			turn_label.set("theme_override_colors/font_color", Color(0.2, 0.95, 1.0))
		else:
			turn_label.text = "ANOMALY TURN"
			turn_label.set("theme_override_colors/font_color", Color(1.0, 0.35, 0.35))
			if is_instance_valid(timer_label):
				timer_label.text = "--"
	_update_buffs_ui()
	if is_instance_valid(sabuk_alkimia):
		sabuk_alkimia.update_ui()

# --- Bottom HUD Handlers ---
func _on_power_updated(percent: float) -> void:
	if is_instance_valid(power_bar):
		power_bar.value = percent
	if is_instance_valid(power_value_label):
		power_value_label.text = "%d%%" % int(percent)
	if is_instance_valid(power_needle) and is_instance_valid(power_bar):
		var bar_w = power_bar.size.x
		var offset_x = (percent / 100.0) * bar_w
		power_needle.position.x = initial_needle_x + offset_x

# --- Spiral Scope Modal Handlers ---
func open_scope_modal(intel: Dictionary) -> void:
	if is_instance_valid(scope_target_label):
		scope_target_label.text = "Target: %s" % intel.get("name", "Anomaly")
	if is_instance_valid(scope_tier_label):
		scope_tier_label.text = "Threat Level: %s" % intel.get("tier", "Common")
	if is_instance_valid(scope_weakness_label):
		scope_weakness_label.text = "Viexir Vulnerability: %s" % intel.get("weakness", "Attack Viexir")
	if is_instance_valid(scope_weakpoint_label):
		var part = intel.get("weak_point", "Head")
		scope_weakpoint_label.text = "🎯 WEAK POINT: %s\n(Target %s for CRITICAL HIT +50%% Damage!)" % [part.to_upper(), part]
		
	if is_instance_valid(spiral_scope_modal):
		spiral_scope_modal.visible = true

func close_scope_modal() -> void:
	if is_instance_valid(spiral_scope_modal):
		spiral_scope_modal.visible = false
	AudioManager.play_click()

# --- Escape Modal Handlers ---
func _on_btn_kabur_pressed() -> void:
	if is_instance_valid(escape_modal):
		escape_modal.visible = true
	AudioManager.play_click()

func close_escape_modal() -> void:
	if is_instance_valid(escape_modal):
		escape_modal.visible = false
	AudioManager.play_click()

func _on_confirm_escape() -> void:
	print("🏃 Player fled from battle! Returning to exploration map...")
	Global.reset_battle_effects()
	AudioManager.play_dodge()
	get_tree().change_scene_to_file("res://scenes/levels/exploration_map.tscn")

# --- Pause Modal Handlers ---
func _toggle_pause() -> void:
	if not is_instance_valid(pause_modal):
		return
	pause_modal.visible = not pause_modal.visible
	AudioManager.play_click()

func _on_return_basecamp() -> void:
	Global.reset_battle_effects()
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://scenes/levels/base_lobby.tscn")
