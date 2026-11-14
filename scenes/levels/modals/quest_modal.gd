extends Control

signal modal_closed

@onready var cari_label: Label = $Card/Scroll/VBox/CariList
@onready var bunuh_label: Label = $Card/Scroll/VBox/BunuhList
@onready var btn_claim: Button = $Card/BtnClaim
@onready var btn_tutup: Button = $Card/BtnTutup

var reward_claimed: bool = false

func _ready() -> void:
	btn_claim.pressed.connect(_on_claim_pressed)
	btn_tutup.pressed.connect(close)

func open() -> void:
	visible = true
	_update_ui()

func close() -> void:
	visible = false
	AudioManager.play_click()
	modal_closed.emit()

func _update_ui() -> void:
	if not is_instance_valid(cari_label): return
	
	var cur_stone = Global.material_inventory.get("stone", 0)
	var cur_iron = Global.material_inventory.get("iron", 0)
	var cur_glass = Global.material_inventory.get("glass", 0)
	var cur_leather = Global.material_inventory.get("leather", 0)
	
	var cur_y_azer = Global.material_inventory.get("yellow_azer", 0)
	var cur_r_azer = Global.material_inventory.get("red_azer", 0)
	var cur_w_azer = Global.material_inventory.get("white_azer", 0)
	var cur_b_azer = Global.material_inventory.get("blue_azer", 0)
	var cur_g_azer = Global.material_inventory.get("green_azer", 0)
	
	cari_label.text = "Stone (%d/10)        Yellow Azer (%d/5)\nIron (%d/15)        Red Azer (%d/5)\nGlass (%d/20)        White Azer (%d/5)\nLeather (%d/25)\nBlue Azer (%d/5)\nGreen Azer (%d/5)" % [
		cur_stone, cur_y_azer, cur_iron, cur_r_azer, cur_glass, cur_w_azer, cur_leather, cur_b_azer, cur_g_azer
	]
	
	bunuh_label.text = "Common Anomaly (%d/20)" % Global.enemies_defeated
	
	var is_all_completed = (
		cur_stone >= 10 and cur_iron >= 15 and cur_glass >= 20 and cur_leather >= 25 and
		cur_y_azer >= 5 and cur_r_azer >= 5 and cur_w_azer >= 5 and cur_b_azer >= 5 and cur_g_azer >= 5 and
		Global.enemies_defeated >= 20
	)
	
	if reward_claimed:
		btn_claim.text = "✅ Quest Completed (Claimed)"
		btn_claim.disabled = true
	elif is_all_completed:
		btn_claim.text = "🎁 CLAIM REWARD (+100 Coins & +50 EXP)"
		btn_claim.disabled = false
	else:
		btn_claim.text = "In Progress (Incomplete)"
		btn_claim.disabled = true

func _on_claim_pressed() -> void:
	if not reward_claimed:
		reward_claimed = true
		Global.add_coins(100)
		Global.gain_exp(50)
		AudioManager.play_coin()
		_update_ui()
