extends Node

signal turn_changed(is_player: bool)
signal timer_ticked(seconds_left: int)

enum Turn { PLAYER, ENEMY }
var current_turn: Turn = Turn.PLAYER

@onready var player: Node2D = $"../Player"
@onready var turn_label: Label = get_node_or_null("../UI/TurnLabel")
@onready var main_camera: Camera2D = $"../MainCamera"

@onready var enemy_delay_timer: Timer = $Timer 
@onready var player_turn_timer: Timer = $PlayerTurnTimer 

const PLAYER_TURN_DURATION: float = 60.0 
var last_emitted_second: int = -1

func _ready() -> void:
	enemy_delay_timer.timeout.connect(_on_enemy_delay_timeout)
	player_turn_timer.timeout.connect(_on_player_turn_timeout)
	start_player_turn()

func _process(_delta: float) -> void:
	if current_turn == Turn.PLAYER and is_instance_valid(player_turn_timer) and not player_turn_timer.is_stopped():
		var s_left = int(ceil(player_turn_timer.time_left))
		if s_left != last_emitted_second:
			last_emitted_second = s_left
			timer_ticked.emit(s_left)

func start_player_turn() -> void:
	if Global.player_hp <= 0 or not is_instance_valid(player):
		return
		
	if player.has_method("evaluate_poison"):
		player.evaluate_poison()
		
	if Global.player_hp <= 0:
		return
	
	current_turn = Turn.PLAYER
	player.is_active = true
	if is_instance_valid(turn_label):
		turn_label.text = "PLAYER TURN"
	turn_changed.emit(true)
	
	print("--- PLAYER TURN STARTED --- | Time: %d sec" % PLAYER_TURN_DURATION)
	
	_update_potion_durations()
	
	# Save Position
	player.position_at_turn_start = player.global_position.x
	main_camera.target = player
	
	player_turn_timer.start(PLAYER_TURN_DURATION)
	last_emitted_second = int(PLAYER_TURN_DURATION)
	timer_ticked.emit(last_emitted_second)
	
func end_player_turn() -> void:
	if is_instance_valid(turn_label):
		turn_label.text = "ENEMY TURN"
	player_turn_timer.stop() 
	
	current_turn = Turn.ENEMY
	player.is_active = false
	turn_changed.emit(false)
	print("--- PLAYER TURN ENDED ---")
	
	enemy_delay_timer.start(2.0)

func _on_player_turn_timeout() -> void:
	if current_turn == Turn.PLAYER:
		print("TIME IS UP! Auto-ending player turn.")
		turn_label.text = "ENEMY TURN"
		
		current_turn = Turn.ENEMY
		player.is_active = false
		
		enemy_delay_timer.start(2.0)

func _on_enemy_delay_timeout() -> void:
	if current_turn == Turn.ENEMY:
		var enemy = $"../Anomaly"
		
		if is_instance_valid(enemy):
			main_camera.target = enemy
			
			if enemy.has_method("start_turn"):
				enemy.start_turn(player)
		else:
			print("No enemy found, battle is over!")

# Potion & Effect Duration Manager
func _update_potion_durations() -> void:
	if Global.invisible_duration > 0:
		Global.invisible_duration -= 1
		if Global.invisible_duration == 0:
			print("Invisible effect ended!")
			
	if Global.wind_duration > 0:
		Global.wind_duration -= 1
		if Global.wind_duration == 0:
			print("Wind effect ended!")
			
	var enemy = $"../Anomaly"
	if is_instance_valid(enemy) and enemy.has_method("update_debuff"):
		enemy.update_debuff()
