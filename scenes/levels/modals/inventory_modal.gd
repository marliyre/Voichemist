extends Control

signal modal_closed

@onready var grid: GridContainer = $Card/TasBox/GridSlots
@onready var desc_label: Label = $Card/DescBanner/Label
@onready var btn_buang: Button = $Card/ActionButtons/BtnBuang
@onready var btn_tutup: Button = $Card/ActionButtons/BtnSimpanTutup

var selected_item: String = ""

func _ready() -> void:
	btn_buang.pressed.connect(_on_buang_pressed)
	btn_tutup.pressed.connect(close)

func open() -> void:
	visible = true
	selected_item = ""
	_update_ui()

func close() -> void:
	visible = false
	AudioManager.play_click()
	modal_closed.emit()

func _update_ui() -> void:
	if not is_instance_valid(grid): return
	
	var active_items: Array[Dictionary] = []
	for k in Global.consumable_inventory.keys():
		if Global.consumable_inventory[k] > 0:
			active_items.append({"id": k, "count": Global.consumable_inventory[k]})
	for k in Global.material_inventory.keys():
		if Global.material_inventory[k] > 0:
			active_items.append({"id": k, "count": Global.material_inventory[k]})
			
	var slots = grid.get_children()
	for i in range(slots.size()):
		var slot_btn: Button = slots[i]
		if i < active_items.size():
			var it = active_items[i]
			var info = ItemData.get_info(it.id)
			slot_btn.text = "%s\n%s\nx%d" % [info.icon, info.title, it.count]
			slot_btn.disabled = false
			slot_btn.modulate = Color(1.2, 1.1, 0.5) if selected_item == it.id else Color.WHITE
			
			for sig in slot_btn.pressed.get_connections():
				slot_btn.pressed.disconnect(sig.callable)
			slot_btn.pressed.connect(func():
				selected_item = it.id
				AudioManager.play_click()
				_update_ui()
			)
			slot_btn.visible = true
		else:
			slot_btn.text = "---\nEmpty"
			slot_btn.disabled = true
			slot_btn.modulate = Color(0.6, 0.6, 0.6, 0.5)
			slot_btn.visible = true
			
	if selected_item != "" and ItemData.DB.has(selected_item):
		var info = ItemData.DB[selected_item]
		desc_label.text = "[%s] %s: %s" % [info.type, info.title, info.desc]
		btn_buang.disabled = false
	else:
		desc_label.text = "Select an item in your bag to inspect its details and effects."
		btn_buang.disabled = true

func _on_buang_pressed() -> void:
	if selected_item != "" and Global.use_item(selected_item, 1):
		AudioManager.play_dodge()
		_update_ui()
