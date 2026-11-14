extends Control

signal modal_closed

@onready var btn_lanjutkan: Button = $Card/BtnLanjutkan
@onready var btn_pengaturan: Button = $Card/BtnPengaturan
@onready var btn_kredit: Button = $Card/BtnKredit
@onready var btn_keluar: Button = $Card/BtnKeluar
@onready var toast_label: Label = $Card/ToastLabel

func _ready() -> void:
	btn_lanjutkan.pressed.connect(close)
	btn_pengaturan.pressed.connect(_on_pengaturan_pressed)
	btn_kredit.pressed.connect(_on_kredit_pressed)
	btn_keluar.pressed.connect(_on_keluar_pressed)

func open() -> void:
	visible = true
	if is_instance_valid(toast_label):
		toast_label.text = ""

func close() -> void:
	visible = false
	AudioManager.play_click()
	modal_closed.emit()

func _on_pengaturan_pressed() -> void:
	AudioManager.play_click()
	if is_instance_valid(toast_label):
		toast_label.text = "Settings: Audio & Music Active (100%)"

func _on_kredit_pressed() -> void:
	AudioManager.play_click()
	if is_instance_valid(toast_label):
		toast_label.text = "Voichemist by Development Team (Godot 4)"

func _on_keluar_pressed() -> void:
	AudioManager.play_click()
	print("Returning to Main Menu...")
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")
