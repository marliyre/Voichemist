extends CharacterBody2D

signal moved_to_cell(grid_pos: Vector2i)

# Grid Layout matching assets/referensi/exploration/contoh exploration.png (13x6 Board)
const GRID_START: Vector2 = Vector2(89.7, 219.0)
const TILE_SIZE: Vector2 = Vector2(74.33, 56.55)
const COLS: int = 13
const ROWS: int = 6

@export var grid_pos: Vector2i = Vector2i(6, 5) # Default start at bottom center (Row 5, Col 6)
@export var move_duration: float = 0.16

var is_moving: bool = false

@onready var ray: RayCast2D = $RayCast2D
@onready var selection_box: Control = get_node_or_null("SelectionBox")
@onready var sprite: CanvasItem = get_node_or_null("Sprite2D")

func _ready() -> void:
	Global.is_exploring = true
	Global.is_in_battle = false
	position = grid_to_world(grid_pos)
	_setup_pulse_effect()

static func grid_to_world(pos: Vector2i) -> Vector2:
	return GRID_START + Vector2((float(pos.x) + 0.5) * TILE_SIZE.x, (float(pos.y) + 0.5) * TILE_SIZE.y)

static func world_to_grid(world_pos: Vector2) -> Vector2i:
	var col: int = int(floor((world_pos.x - GRID_START.x) / TILE_SIZE.x))
	var row: int = int(floor((world_pos.y - GRID_START.y) / TILE_SIZE.y))
	return Vector2i(clampi(col, 0, COLS - 1), clampi(row, 0, ROWS - 1))

func _setup_pulse_effect() -> void:
	if is_instance_valid(selection_box):
		var tw: Tween = create_tween().set_loops()
		tw.tween_property(selection_box, "modulate:a", 0.65, 0.7).set_trans(Tween.TRANS_SINE)
		tw.tween_property(selection_box, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE)

func _unhandled_input(event: InputEvent) -> void:
	if is_moving or not Global.is_exploring:
		return
		
	var target_dir: Vector2i = Vector2i.ZERO
	if event.is_action_pressed("ui_right") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_D):
		target_dir = Vector2i.RIGHT
	elif event.is_action_pressed("ui_left") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_A):
		target_dir = Vector2i.LEFT
	elif event.is_action_pressed("ui_up") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_W):
		target_dir = Vector2i.UP
	elif event.is_action_pressed("ui_down") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_S):
		target_dir = Vector2i.DOWN
		
	if target_dir != Vector2i.ZERO:
		try_move_direction(target_dir)

func try_move_direction(dir: Vector2i) -> void:
	var next_cell: Vector2i = grid_pos + dir
	if next_cell.x < 0 or next_cell.x >= COLS or next_cell.y < 0 or next_cell.y >= ROWS:
		_shake_tile(dir)
		return
	move_to_cell(next_cell)

func move_to_cell(target_cell: Vector2i) -> void:
	if is_moving:
		return
	is_moving = true
	grid_pos = target_cell
	var target_world: Vector2 = grid_to_world(grid_pos)
	
	AudioManager.play_click()
	
	# Raycast pre-check
	if is_instance_valid(ray):
		ray.target_position = target_world - position
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider: Object = ray.get_collider()
			if is_instance_valid(collider):
				if collider.has_method("collect_azer"):
					collider.collect_azer()
				elif collider.has_method("collect_loot"):
					collider.collect_loot()
				elif collider.has_method("enter_battle"):
					Global.is_exploring = false
					collider.enter_battle()
					is_moving = false
					return
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target_world, move_duration).set_trans(Tween.TRANS_SINE)
	await tween.finished
	is_moving = false
	moved_to_cell.emit(grid_pos)
	
	# Fallback tile overlap check
	_check_tile_interaction()

func _check_tile_interaction() -> void:
	var parent: Node = get_parent()
	if not is_instance_valid(parent):
		return
	for child in parent.get_children():
		if child == self:
			continue
		if child is Area2D or child is Node2D:
			if child.global_position.distance_to(position) < 32.0:
				if child.has_method("collect_azer"):
					child.collect_azer()
				elif child.has_method("collect_loot"):
					child.collect_loot()
				elif child.has_method("enter_battle"):
					Global.is_exploring = false
					child.enter_battle()
					return

func _shake_tile(dir: Vector2i) -> void:
	var tw: Tween = create_tween()
	var offset: Vector2 = Vector2(dir.x * 6.0, dir.y * 6.0)
	var orig_pos: Vector2 = position
	tw.tween_property(self, "position", orig_pos + offset, 0.05)
	tw.tween_property(self, "position", orig_pos, 0.05)
