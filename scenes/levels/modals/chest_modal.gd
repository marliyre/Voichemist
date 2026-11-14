extends Control

signal modal_closed

@onready var peti_grid: GridContainer = $Card/PetiBox/PetiGrid
@onready var tas_grid: GridContainer = $Card/TasBox/TasGrid
@onready var btn_tutup: Button = $Card/BtnSimpanTutup

func _ready() -> void:
	btn_tutup.pressed.connect(close)

func open() -> void:
	visible = true
	_update_ui()

func close() -> void:
	visible = false
	AudioManager.play_click()
	modal_closed.emit()

func _update_ui() -> void:
	if not is_instance_valid(peti_grid) or not is_instance_valid(tas_grid): return
	
	# 1. Peti (30 Slots)
	var chest_items: Array[Dictionary] = []
	for k in Global.chest_inventory.keys():
		if Global.chest_inventory[k] > 0:
			chest_items.append({"id": k, "count": Global.chest_inventory[k]})
			
	var peti_slots = peti_grid.get_children()
	for i in range(peti_slots.size()):
		var btn: Button = peti_slots[i]
		if i < chest_items.size():
			var it = chest_items[i]
			var info = ItemData.get_info(it.id)
			btn.text = "%s\n%s\nx%d" % [info.icon, info.title, it.count]
			btn.disabled = false
			for sig in btn.pressed.get_connections(): btn.pressed.disconnect(sig.callable)
			btn.pressed.connect(func():
				Global.transfer_from_chest(it.id, 1)
				AudioManager.play_coin()
				_update_ui()
			)
		else:
			btn.text = "---\nEmpty"
			btn.disabled = true
			
	# 2. Tas (15 Slots)
	var bag_items: Array[Dictionary] = []
	for k in Global.consumable_inventory.keys():
		if Global.consumable_inventory[k] > 0:
			bag_items.append({"id": k, "count": Global.consumable_inventory[k]})
	for k in Global.material_inventory.keys():
		if Global.material_inventory[k] > 0:
			bag_items.append({"id": k, "count": Global.material_inventory[k]})
			
	var tas_slots = tas_grid.get_children()
	for i in range(tas_slots.size()):
		var btn: Button = tas_slots[i]
		if i < bag_items.size():
			var it = bag_items[i]
			var info = ItemData.get_info(it.id)
			btn.text = "%s\n%s\nx%d" % [info.icon, info.title, it.count]
			btn.disabled = false
			for sig in btn.pressed.get_connections(): btn.pressed.disconnect(sig.callable)
			btn.pressed.connect(func():
				Global.transfer_to_chest(it.id, 1)
				AudioManager.play_coin()
				_update_ui()
			)
		else:
			btn.text = "---\nEmpty"
			btn.disabled = true
