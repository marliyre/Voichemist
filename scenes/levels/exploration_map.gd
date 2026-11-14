extends Node2D

# Exploration Map Controller - Voichemist
# Matches layout & visual aesthetics of assets/referensi/exploration/contoh exploration.png

@onready var player: CharacterBody2D = $PlayerExplorer

# HUD References
@onready var player_name_label: Label = $UI/TopHUD/PlayerProfileCard/HBox/VBox/HeaderRow/PlayerNameLabel
@onready var coins_label: Label = $UI/TopHUD/PlayerProfileCard/HBox/VBox/HeaderRow/CoinsLabel
@onready var hp_bar: ProgressBar = $UI/TopHUD/PlayerProfileCard/HBox/VBox/HPBar
@onready var hp_label: Label = $UI/TopHUD/PlayerProfileCard/HBox/VBox/HPBar/Label
@onready var sp_bar: ProgressBar = $UI/TopHUD/PlayerProfileCard/HBox/VBox/SPBar
@onready var sp_label: Label = $UI/TopHUD/PlayerProfileCard/HBox/VBox/SPBar/Label
@onready var exp_bar: ProgressBar = $UI/TopHUD/PlayerProfileCard/HBox/VBox/EXPBar
@onready var exp_label: Label = $UI/TopHUD/PlayerProfileCard/HBox/VBox/EXPBar/Label

@onready var btn_pause: Button = $UI/TopHUD/BtnPause
@onready var btn_return_base: Button = $UI/BtnReturnBase

# Pause Modal
@onready var pause_modal: Control = $UI/PauseModal
@onready var pause_btn_lanjutkan: Button = $UI/PauseModal/Card/BtnLanjutkan
@onready var pause_btn_kembali: Button = $UI/PauseModal/Card/BtnKembali
@onready var pause_btn_pengaturan: Button = $UI/PauseModal/Card/BtnPengaturan
@onready var pause_btn_keluar: Button = $UI/PauseModal/Card/BtnKeluar
@onready var pause_toast_label: Label = $UI/PauseModal/Card/ToastLabel

# Tile Grid dimensions
const GRID_START: Vector2 = Vector2(89.7, 219.0)
const TILE_SIZE: Vector2 = Vector2(74.33, 56.55)
const COLS: int = 13
const ROWS: int = 6

func _ready() -> void:
	Global.is_exploring = true
	Global.is_in_battle = false
	
	_connect_signals()
	_update_hud()
	
	if is_instance_valid(pause_modal):
		pause_modal.visible = false

func _connect_signals() -> void:
	if is_instance_valid(btn_pause):
		btn_pause.pressed.connect(open_pause_modal)
	if is_instance_valid(btn_return_base):
		btn_return_base.pressed.connect(_return_to_basecamp)
		
	if is_instance_valid(pause_btn_lanjutkan):
		pause_btn_lanjutkan.pressed.connect(close_pause_modal)
	if is_instance_valid(pause_btn_kembali):
		pause_btn_kembali.pressed.connect(_return_to_basecamp)
	if is_instance_valid(pause_btn_pengaturan):
		pause_btn_pengaturan.pressed.connect(_on_pause_pengaturan_pressed)
	if is_instance_valid(pause_btn_keluar):
		pause_btn_keluar.pressed.connect(_on_pause_keluar_pressed)

func _process(_delta: float) -> void:
	_update_hud()

func _update_hud() -> void:
	if is_instance_valid(player_name_label):
		player_name_label.text = "ALCHEMIST (Lv. %d)" % Global.player_level
	if is_instance_valid(coins_label):
		coins_label.text = "💰 %d Coins" % Global.coins
		
	if is_instance_valid(hp_bar):
		hp_bar.max_value = Global.max_hp
		hp_bar.value = Global.player_hp
	if is_instance_valid(hp_label):
		hp_label.text = "%d / %d" % [Global.player_hp, Global.max_hp]
		
	if is_instance_valid(sp_bar):
		sp_bar.max_value = Global.max_sp
		sp_bar.value = Global.current_sp
	if is_instance_valid(sp_label):
		sp_label.text = "%d / %d" % [Global.current_sp, Global.max_sp]
		
	if is_instance_valid(exp_bar):
		exp_bar.max_value = Global.exp_needed
		exp_bar.value = Global.current_exp
	if is_instance_valid(exp_label):
		exp_label.text = "%d / %d EXP" % [Global.current_exp, Global.exp_needed]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_instance_valid(pause_modal) and pause_modal.visible:
			close_pause_modal()
		else:
			open_pause_modal()
		get_viewport().set_input_as_handled()
		return
		
	# Mouse / Touch movement on the 13x6 Board
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_instance_valid(pause_modal) and pause_modal.visible:
			return
		if not is_instance_valid(player) or player.is_moving:
			return
			
		var clicked_cell: Vector2i = player.world_to_grid(event.position)
		var diff: Vector2i = clicked_cell - player.grid_pos
		var manhattan_dist: int = abs(diff.x) + abs(diff.y)
		if manhattan_dist == 1:
			player.try_move_direction(diff)

func open_pause_modal() -> void:
	AudioManager.play_click()
	if is_instance_valid(pause_modal):
		pause_modal.visible = true
	if is_instance_valid(pause_toast_label):
		pause_toast_label.text = ""

func close_pause_modal() -> void:
	AudioManager.play_click()
	if is_instance_valid(pause_modal):
		pause_modal.visible = false

func _return_to_basecamp() -> void:
	AudioManager.play_click()
	Global.is_exploring = false
	print("🚪 Moving to Basecamp...")
	get_tree().change_scene_to_file("res://scenes/levels/base_lobby.tscn")

func _on_pause_pengaturan_pressed() -> void:
	AudioManager.play_click()
	if is_instance_valid(pause_toast_label):
		pause_toast_label.text = "Sound and graphics settings optimal (60 FPS)."

func _on_pause_keluar_pressed() -> void:
	AudioManager.play_click()
	if is_instance_valid(pause_toast_label):
		pause_toast_label.text = "Saving expedition data & returning to Basecamp..."
	await get_tree().create_timer(0.4).timeout
	_return_to_basecamp()
