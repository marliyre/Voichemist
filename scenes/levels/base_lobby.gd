extends Node2D

@onready var floating_tooltip: PanelContainer = $UI/FloatingTooltip
@onready var tooltip_label: Label = $UI/FloatingTooltip/Label

# Player Profile HUD
@onready var player_name_label: Label = $UI/TopHUD/PlayerProfileCard/HBox/VBox/HeaderRow/PlayerNameLabel
@onready var coins_label: Label = $UI/TopHUD/PlayerProfileCard/HBox/VBox/HeaderRow/CoinsLabel
@onready var hp_bar: ProgressBar = $UI/TopHUD/PlayerProfileCard/HBox/VBox/HPBar
@onready var hp_label: Label = $UI/TopHUD/PlayerProfileCard/HBox/VBox/HPBar/Label
@onready var sp_bar: ProgressBar = $UI/TopHUD/PlayerProfileCard/HBox/VBox/SPBar
@onready var sp_label: Label = $UI/TopHUD/PlayerProfileCard/HBox/VBox/SPBar/Label
@onready var exp_bar: ProgressBar = $UI/TopHUD/PlayerProfileCard/HBox/VBox/EXPBar
@onready var exp_label: Label = $UI/TopHUD/PlayerProfileCard/HBox/VBox/EXPBar/Label
@onready var btn_rest: Button = $UI/TopHUD/BtnRest
@onready var btn_pause: Button = $UI/TopHUD/BtnPause

# Hotspots
@onready var hotspot_cave: Button = $UI/Hotspots/HotspotCave
@onready var hotspot_cauldron: Button = $UI/Hotspots/HotspotCauldron
@onready var hotspot_door: Button = $UI/Hotspots/HotspotDoor
@onready var hotspot_workbench: Button = $UI/Hotspots/HotspotWorkbench
@onready var hotspot_chest: Button = $UI/Hotspots/HotspotChest
@onready var hotspot_target: Button = $UI/Hotspots/HotspotTarget
@onready var hotspot_book: Button = $UI/Hotspots/HotspotBook
@onready var hotspot_bag: Button = $UI/Hotspots/HotspotBag

# Sub-modal Controllers
@onready var modal_workbench: Control = $UI/Modals/WorkbenchModal
@onready var modal_brewing: Control = $UI/Modals/BrewingModal
@onready var modal_shop: Control = $UI/Modals/ShopModal
@onready var modal_inventory: Control = $UI/Modals/InventoryModal
@onready var modal_chest: Control = $UI/Modals/ChestModal
@onready var modal_quest: Control = $UI/Modals/QuestModal
@onready var modal_guide: Control = $UI/Modals/GuideBookModal
@onready var modal_pause: Control = $UI/Modals/PauseModal

var _all_modals: Array[Control] = []
var _last_hp: int = -1
var _last_sp: int = -1
var _last_exp: int = -1
var _last_lvl: int = -1
var _last_coins: int = -1

func _ready() -> void:
	Global.is_in_battle = false
	Global.is_exploring = false
	Global.reset_battle_effects()

	_all_modals = [
		modal_workbench, modal_brewing, modal_shop, modal_inventory,
		modal_chest, modal_quest, modal_guide, modal_pause
	]

	_connect_hotspots()
	close_all_modals()
	_update_hud(true)

func _process(_delta: float) -> void:
	_update_hud(false)

func _update_hud(force: bool = false) -> void:
	if force or Global.player_level != _last_lvl:
		_last_lvl = Global.player_level
		player_name_label.text = "PLAYER (Lv. %d)" % Global.player_level

	if force or Global.coins != _last_coins:
		_last_coins = Global.coins
		coins_label.text = "💰 %d Coins" % Global.coins

	if force or Global.player_hp != _last_hp or hp_bar.max_value != Global.max_hp:
		_last_hp = Global.player_hp
		hp_bar.max_value = Global.max_hp
		hp_bar.value = Global.player_hp
		hp_label.text = "%d / %d" % [Global.player_hp, Global.max_hp]

	if force or Global.current_sp != _last_sp or sp_bar.max_value != Global.max_sp:
		_last_sp = Global.current_sp
		sp_bar.max_value = Global.max_sp
		sp_bar.value = Global.current_sp
		sp_label.text = "%d / %d" % [Global.current_sp, Global.max_sp]

	if force or Global.current_exp != _last_exp or exp_bar.max_value != Global.exp_needed:
		_last_exp = Global.current_exp
		exp_bar.max_value = Global.exp_needed
		exp_bar.value = Global.current_exp
		exp_label.text = "%d / %d EXP" % [Global.current_exp, Global.exp_needed]

func _connect_hotspots() -> void:
	_setup_hotspot(hotspot_cave, "🗺️ Exploration Cave (Enter Dungeon Run)", func():
		AudioManager.play_dodge()
		get_tree().change_scene_to_file("res://scenes/levels/exploration_map.tscn")
	)
	_setup_hotspot(hotspot_cauldron, "🧪 Alchemy Lab (Brew Potions & Viexirs)", func(): open_modal(modal_brewing))
	_setup_hotspot(hotspot_workbench, "🔨 Container Workbench (Craft Viex & Scope Containers)", func(): open_modal(modal_workbench))
	_setup_hotspot(hotspot_door, "🏪 Alchemy Shop (Buy & Sell Items)", func(): open_modal(modal_shop))
	_setup_hotspot(hotspot_chest, "📦 Storage Chest (30-Slot Stash)", func(): open_modal(modal_chest))
	_setup_hotspot(hotspot_target, "🎯 Quest Board (Tasks & Rewards)", func(): open_modal(modal_quest))
	_setup_hotspot(hotspot_book, "📖 Voichemist Guidebook (Manual & Tips)", func(): open_modal(modal_guide))
	_setup_hotspot(hotspot_bag, "🎒 Alchemist Backpack (15-Slot Inventory)", func(): open_modal(modal_inventory))

	btn_rest.pressed.connect(_on_rest_pressed)
	btn_pause.pressed.connect(func(): open_modal(modal_pause))

func _setup_hotspot(btn: Button, tip: String, on_click: Callable) -> void:
	if not is_instance_valid(btn): return
	btn.mouse_entered.connect(func(): _show_tooltip(btn, tip))
	btn.mouse_exited.connect(_hide_tooltip)
	btn.pressed.connect(func():
		AudioManager.play_click()
		_hide_tooltip()
		on_click.call()
	)

func _show_tooltip(btn: Button, text: String) -> void:
	if not is_instance_valid(floating_tooltip) or not is_instance_valid(tooltip_label): return
	tooltip_label.text = text
	floating_tooltip.visible = true
	var pos = btn.global_position + Vector2(btn.size.x * 0.5 - floating_tooltip.size.x * 0.5, -35)
	pos.x = clamp(pos.x, 20.0, 1152.0 - floating_tooltip.size.x - 20.0)
	floating_tooltip.position = pos

func _hide_tooltip() -> void:
	if is_instance_valid(floating_tooltip):
		floating_tooltip.visible = false

func _on_rest_pressed() -> void:
	Global.rest_at_base()
	AudioManager.play_coin()
	_update_hud(true)

func open_modal(modal: Control) -> void:
	close_all_modals()
	if is_instance_valid(modal) and modal.has_method("open"):
		modal.open()

func close_all_modals() -> void:
	for m in _all_modals:
		if is_instance_valid(m):
			m.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if _is_any_modal_open():
				close_all_modals()
				AudioManager.play_click()
			else:
				open_modal(modal_pause)

func _is_any_modal_open() -> bool:
	for m in _all_modals:
		if is_instance_valid(m) and m.visible:
			return true
	return false
