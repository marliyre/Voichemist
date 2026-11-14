extends Control

signal modal_closed

@onready var container: VBoxContainer = $Card/VBox/Scroll/VBox
@onready var btn_kembali: Button = $Card/VBox/BtnKembali
@onready var notice_label: Label = $Card/VBox/NoticeLabel

const RECIPES: Array[Dictionary] = [
	{"id": "attack_viexir", "title": "Attack Viexir", "mats": {"viex": 1, "red_crystal": 1}},
	{"id": "neutralize_viexir", "title": "Neutralize Viexir", "mats": {"viex": 1, "green_crystal": 1}},
	{"id": "defense_viexir", "title": "Defense Viexir", "mats": {"viex": 1, "blue_crystal": 1}},
	{"id": "spiral_scope", "title": "Spiral Scope", "mats": {"scope": 1, "blue_crystal": 1, "gold_crystal": 1, "red_azer": 1}},
	{"id": "heal_potion", "title": "Health Potion", "mats": {"glass": 1, "green_crystal": 1, "green_azer": 1}},
	{"id": "stamina_potion", "title": "Stamina Potion", "mats": {"glass": 1, "green_crystal": 1, "yellow_azer": 1}},
	{"id": "invisible_potion", "title": "Invisibility Potion", "mats": {"glass": 1, "green_crystal": 1, "white_azer": 1}},
	{"id": "wind_potion", "title": "Wind Potion", "mats": {"glass": 1, "green_crystal": 1, "blue_azer": 1}}
]

func _ready() -> void:
	btn_kembali.pressed.connect(close)

func open() -> void:
	visible = true
	_set_notice("", Color.WHITE)
	_update_ui()

func close() -> void:
	visible = false
	AudioManager.play_click()
	modal_closed.emit()

func _update_ui() -> void:
	if not is_instance_valid(container): return
	for child in container.get_children():
		child.queue_free()
		
	for rec in RECIPES:
		var row = HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 44)
		row.add_theme_constant_override("separation", 12)
		
		var lbl = Label.new()
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.text = "%s (%s)" % [rec.title, _format_cost(rec.mats)]
		row.add_child(lbl)
		
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(110, 36)
		btn.text = "🧪 Brew"
		var can_craft = _can_craft(rec.mats)
		btn.disabled = not can_craft
		btn.pressed.connect(func(): _execute_brewing(rec))
		row.add_child(btn)
		
		container.add_child(row)

func _format_cost(mats: Dictionary) -> String:
	var parts: Array[String] = []
	for k in mats.keys():
		var info = ItemData.get_info(k)
		var cur = Global.material_inventory.get(k, 0)
		parts.append("%s: %d/%d" % [info.title, cur, mats[k]])
	return ", ".join(parts)

func _can_craft(mats: Dictionary) -> bool:
	for k in mats.keys():
		if Global.material_inventory.get(k, 0) < mats[k]:
			return false
	return true

func _execute_brewing(rec: Dictionary) -> void:
	if not _can_craft(rec.mats):
		_set_notice("❌ Insufficient materials!", Color(1, 0.4, 0.4))
		AudioManager.play_click()
		return
		
	for k in rec.mats.keys():
		Global.material_inventory[k] -= rec.mats[k]
	Global.add_item(rec.id, 1)
	Global.gain_exp(15)
	AudioManager.play_coin()
	_set_notice("✅ Successfully brewed 1 %s! (+15 EXP)" % rec.title, Color(0.3, 1, 0.4))
	_update_ui()

func _set_notice(msg: String, col: Color) -> void:
	if is_instance_valid(notice_label):
		notice_label.text = msg
		notice_label.set("theme_override_colors/font_color", col)
