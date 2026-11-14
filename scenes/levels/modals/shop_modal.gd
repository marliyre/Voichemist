extends Control

signal modal_closed

@onready var title_label: Label = $Card/Header/TitleLabel
@onready var item_icon: Label = $Card/ItemCard/Left/IconLabel
@onready var owned_count: Label = $Card/ItemCard/Left/OwnedBadge/CountLabel
@onready var item_name: Label = $Card/ItemCard/Center/NameLabel
@onready var item_desc: Label = $Card/ItemCard/Center/DescLabel
@onready var price_label: Label = $Card/ActionRow/PriceLabel
@onready var qty_label: Label = $Card/ActionRow/QuantitySelector/LabelQty
@onready var btn_minus: Button = $Card/ActionRow/QuantitySelector/BtnMinus
@onready var btn_plus: Button = $Card/ActionRow/QuantitySelector/BtnPlus
@onready var btn_action: Button = $Card/ActionRow/BtnAction
@onready var btn_toggle_mode: Button = $Card/BottomRow/BtnToggleMode
@onready var btn_kembali: Button = $Card/BottomRow/BtnKembali
@onready var btn_prev: Button = $Card/ItemCard/BtnPrev
@onready var btn_next: Button = $Card/ItemCard/BtnNext
@onready var notice_label: Label = $Card/NoticeLabel

var is_sell_mode: bool = false
var selected_index: int = 0
var quantity: int = 1

const ITEM_LIST: Array[String] = [
	"attack_viexir", "neutralize_viexir", "defense_viexir", "spiral_scope",
	"heal_potion", "stamina_potion", "invisible_potion", "wind_potion",
	"stone", "iron", "glass", "leather"
]

func _ready() -> void:
	btn_minus.pressed.connect(func():
		quantity = max(1, quantity - 1)
		AudioManager.play_click()
		_update_ui()
	)
	btn_plus.pressed.connect(func():
		quantity = min(99, quantity + 1)
		AudioManager.play_click()
		_update_ui()
	)
	btn_prev.pressed.connect(func():
		selected_index = (selected_index - 1 + ITEM_LIST.size()) % ITEM_LIST.size()
		AudioManager.play_click()
		_update_ui()
	)
	btn_next.pressed.connect(func():
		selected_index = (selected_index + 1) % ITEM_LIST.size()
		AudioManager.play_click()
		_update_ui()
	)
	btn_toggle_mode.pressed.connect(func():
		is_sell_mode = not is_sell_mode
		quantity = 1
		AudioManager.play_click()
		_update_ui()
	)
	btn_action.pressed.connect(_on_action_pressed)
	btn_kembali.pressed.connect(close)

func open() -> void:
	visible = true
	is_sell_mode = false
	selected_index = 0
	quantity = 1
	_set_notice("", Color.WHITE)
	_update_ui()

func close() -> void:
	visible = false
	AudioManager.play_click()
	modal_closed.emit()

func _update_ui() -> void:
	if not is_instance_valid(title_label): return
	
	if is_sell_mode:
		title_label.text = "ALCHEMY SHOP - SELL ITEMS"
		btn_toggle_mode.text = "GO BUY"
		btn_action.text = "SELL"
	else:
		title_label.text = "ALCHEMY SHOP - BUY ITEMS"
		btn_toggle_mode.text = "GO SELL"
		btn_action.text = "BUY"
		
	var item_id = ITEM_LIST[selected_index]
	var info = ItemData.get_info(item_id)
	
	var owned: int = 0
	if Global.consumable_inventory.has(item_id):
		owned = Global.consumable_inventory[item_id]
	elif Global.material_inventory.has(item_id):
		owned = Global.material_inventory[item_id]
		
	item_icon.text = info.icon
	owned_count.text = str(owned)
	item_name.text = info.title
	item_desc.text = info.desc
	
	var unit_price = info.price_sell if is_sell_mode else info.price_buy
	var total_price = unit_price * quantity
	price_label.text = "💰 %d Coins" % total_price
	qty_label.text = str(quantity)
	
	btn_action.disabled = (owned < quantity) if is_sell_mode else (Global.coins < total_price)

func _on_action_pressed() -> void:
	var item_id = ITEM_LIST[selected_index]
	var info = ItemData.get_info(item_id)
	
	if is_sell_mode:
		if Global.use_item(item_id, quantity):
			var gain = info.price_sell * quantity
			Global.add_coins(gain)
			AudioManager.play_coin()
			_set_notice("✅ Sold %dx %s (+%d Coins)!" % [quantity, info.title, gain], Color(0.3, 1, 0.4))
		else:
			_set_notice("❌ Insufficient stock to sell!", Color(1, 0.4, 0.4))
	else:
		var cost = info.price_buy * quantity
		if Global.coins >= cost:
			Global.use_coins(cost)
			Global.add_item(item_id, quantity)
			AudioManager.play_coin()
			_set_notice("✅ Purchased %dx %s (-%d Coins)!" % [quantity, info.title, cost], Color(0.3, 1, 0.4))
		else:
			_set_notice("❌ Insufficient coins!", Color(1, 0.4, 0.4))
			
	_update_ui()

func _set_notice(msg: String, col: Color) -> void:
	if is_instance_valid(notice_label):
		notice_label.text = msg
		notice_label.set("theme_override_colors/font_color", col)
