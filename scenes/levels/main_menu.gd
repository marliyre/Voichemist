extends Control

# Main Menu Controller - Voichemist
# Matches layout & visual aesthetics of assets/referensi/main menu/contoh.png

@onready var btn_mulai: Button = $VBoxButtons/BtnMulai
@onready var btn_pengaturan: Button = $VBoxButtons/BtnPengaturan
@onready var btn_keluar: Button = $VBoxButtons/BtnKeluar
@onready var btn_kredit: Button = $BtnKredit

# Settings Modal
@onready var settings_modal: Control = $Modals/SettingsModal
@onready var slider_sfx: HSlider = $Modals/SettingsModal/Card/VBox/SFXRow/SliderSFX
@onready var label_sfx_val: Label = $Modals/SettingsModal/Card/VBox/SFXRow/LabelVal
@onready var btn_mute: Button = $Modals/SettingsModal/Card/VBox/BtnMute
@onready var btn_fullscreen: Button = $Modals/SettingsModal/Card/VBox/BtnFullscreen
@onready var btn_close_settings: Button = $Modals/SettingsModal/Card/BtnCloseSettings

# Credits Modal
@onready var credits_modal: Control = $Modals/CreditsModal
@onready var btn_close_credits: Button = $Modals/CreditsModal/Card/BtnCloseCredits

# Fader / Transition overlay
@onready var fader: ColorRect = $Fader

func _ready() -> void:
	Global.is_in_battle = false
	Global.is_exploring = false
	
	_connect_buttons()
	_init_settings_values()
	
	if is_instance_valid(settings_modal):
		settings_modal.visible = false
	if is_instance_valid(credits_modal):
		credits_modal.visible = false
		
	# Smooth fade in from black on start
	if is_instance_valid(fader):
		fader.visible = true
		fader.modulate.a = 1.0
		var tw = create_tween()
		tw.tween_property(fader, "modulate:a", 0.0, 0.5)
		await tw.finished
		fader.visible = false

func _connect_buttons() -> void:
	btn_mulai.pressed.connect(_on_mulai_pressed)
	btn_pengaturan.pressed.connect(_open_settings)
	btn_keluar.pressed.connect(_on_keluar_pressed)
	btn_kredit.pressed.connect(_open_credits)
	
	btn_close_settings.pressed.connect(_close_all_modals)
	btn_close_credits.pressed.connect(_close_all_modals)
	
	btn_mute.pressed.connect(_on_toggle_mute_pressed)
	btn_fullscreen.pressed.connect(_on_toggle_fullscreen_pressed)
	
	slider_sfx.value_changed.connect(_on_sfx_slider_changed)
	
	# Hover sounds
	for btn in [btn_mulai, btn_pengaturan, btn_keluar, btn_kredit, btn_close_settings, btn_close_credits]:
		btn.mouse_entered.connect(func(): AudioManager.play_click())

func _init_settings_values() -> void:
	slider_sfx.value = AudioManager.sfx_volume * 100.0
	label_sfx_val.text = "%d%%" % int(slider_sfx.value)
	_update_mute_button_label()
	_update_fullscreen_button_label()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if (is_instance_valid(settings_modal) and settings_modal.visible) or \
		   (is_instance_valid(credits_modal) and credits_modal.visible):
			_close_all_modals()
			get_viewport().set_input_as_handled()

func _on_mulai_pressed() -> void:
	AudioManager.play_coin()
	btn_mulai.disabled = true
	btn_pengaturan.disabled = true
	btn_keluar.disabled = true
	
	# Smooth fade out before loading Basecamp
	if is_instance_valid(fader):
		fader.visible = true
		fader.modulate.a = 0.0
		var tw = create_tween()
		tw.tween_property(fader, "modulate:a", 1.0, 0.45)
		await tw.finished
		
	print("🏰 Starting game: Moving to Basecamp...")
	get_tree().change_scene_to_file("res://scenes/levels/base_lobby.tscn")

func _open_settings() -> void:
	AudioManager.play_click()
	_close_all_modals()
	settings_modal.visible = true

func _open_credits() -> void:
	AudioManager.play_click()
	_close_all_modals()
	credits_modal.visible = true

func _close_all_modals() -> void:
	AudioManager.play_click()
	if is_instance_valid(settings_modal):
		settings_modal.visible = false
	if is_instance_valid(credits_modal):
		credits_modal.visible = false

func _on_sfx_slider_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value / 100.0)
	label_sfx_val.text = "%d%%" % int(value)
	_update_mute_button_label()

func _on_toggle_mute_pressed() -> void:
	var muted = AudioManager.toggle_mute()
	AudioManager.play_click()
	_update_mute_button_label()

func _update_mute_button_label() -> void:
	if AudioManager.is_muted:
		btn_mute.text = "🔇 Sound: MUTED"
	else:
		btn_mute.text = "🔊 Sound: ON (%d%%)" % int(AudioManager.sfx_volume * 100.0)

func _on_toggle_fullscreen_pressed() -> void:
	AudioManager.play_click()
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_update_fullscreen_button_label()

func _update_fullscreen_button_label() -> void:
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		btn_fullscreen.text = "🖥️ Screen Mode: FULLSCREEN"
	else:
		btn_fullscreen.text = "🖥️ Screen Mode: WINDOWED"

func _on_keluar_pressed() -> void:
	AudioManager.play_click()
	print("👋 Quitting Voichemist...")
	if is_instance_valid(fader):
		fader.visible = true
		fader.modulate.a = 0.0
		var tw = create_tween()
		tw.tween_property(fader, "modulate:a", 1.0, 0.3)
		await tw.finished
	get_tree().quit()
