extends CharacterBody2D

enum State {
	CHASE,
	FIRE
}

var current_state = State.CHASE

var jps := []
@export var speed : float = 250.0
@export var jump_vel : float = 400.0

var current_target = null
var current_jp = null
var is_jumping := false
var retarget_timer := 0.0
@export var retarget_time := 5.0

var to_target := Vector2.ZERO
var distance_to_target := INF

var same_level := false
var target_above := false
var target_below := false

@export var gravity := 900.0
@onready var weapon = $Weapon

func _ready():
	jps = get_jps()
	add_to_group("entities")
	
func _physics_process(delta):
	think(delta)
	
	match current_state:
		State.CHASE:
			state_chase(delta)
		State.FIRE:
			state_fire(delta)
	
	apply_gravity(delta)
	
	if is_on_floor():
		is_jumping = false
	
	move_and_slide()

func think(delta):
	retarget_timer -= delta
	var old_target = current_target
	
	# --- 1. ПОИСК ЦЕЛИ ---
	if retarget_timer <= 0:
		var enemies = get_enemies()
		current_target = find_enemy(enemies)
		retarget_timer = retarget_time
		
		if current_target != old_target:
			current_jp = null
	
	if current_target == null:
		current_jp = null
		current_state = State.CHASE
		return
	
	# --- 2. АНАЛИЗ ---
	to_target = current_target.global_position - global_position
	distance_to_target = to_target.length()
	
	same_level = abs(to_target.y) <= 40
	target_above = to_target.y < -40
	target_below = to_target.y > 40
	
	# --- 3. ПОИСК JP ---
	if target_above:
		current_jp = find_jp_same_level()
	else:
		current_jp = null
	
	# --- 4. ВЫБОР СОСТОЯНИЯ ---
	if same_level and distance_to_target <= 50:
		current_state = State.FIRE
	else:
		current_state = State.CHASE

func state_chase(delta):
	if current_target == null:
		velocity.x = 0
		return
	
	if is_jumping:
		return
	
	# --- НА ОДНОМ УРОВНЕ ---
	if same_level:
		var dir = sign(to_target.x)
		velocity.x = dir * speed
		return
	
	# --- ВЫШЕ ---
	if target_above:
		if current_jp == null:
			velocity.x = 0
			return
		
		var to_jp = current_jp.global_position - global_position
		var dir = sign(to_jp.x)
		
		velocity.x = dir * speed
		
		if abs(to_jp.x) <= 50:
			velocity.y = -current_jp.jump_force
			is_jumping = true
			current_jp = null
		
		return
	
	# --- НИЖЕ ---
	if target_below:
		var center_x = 0
		var dir = sign(center_x - global_position.x)
		velocity.x = dir * speed
		return

func state_fire(delta):
	if current_target == null:
		return
	
	velocity.x = 0
	
	var dir = (current_target.global_position - global_position).normalized()
	
	weapon.ai_shoot(dir)

func get_jps():
	return get_tree().get_nodes_in_group("jump_points")

func get_enemies():
	var result := []
	var my_team = get_node("Team").team
	
	for e in get_tree().get_nodes_in_group("entities"):
		if e == self:
			continue
		if not e.has_node("Team"):
			continue
		
		if e.get_node("Team").team != my_team:
			result.append(e)
	
	return result
	
func find_enemy(enemies):
	var best = null
	var best_dist = INF
	
	for e in enemies:
		var dist = global_position.distance_to(e.global_position)
		if dist < best_dist:
			best = e
			best_dist = dist
	
	return best

func find_jp_same_level():
	var forward_best = null
	var forward_dist = INF
	
	var back_best = null
	var back_dist = INF
	
	var to_target = current_target.global_position - global_position
	var target_dir = get_dir(to_target.x)
	
	for jp in get_jps():
		if abs(jp.global_position.y - global_position.y) > 40:
			continue
		
		var to_jp = jp.global_position - global_position
		var dist = to_jp.length()
		var jp_dir = get_dir(to_jp.x)
		
		if jp_dir == target_dir:
			if dist < forward_dist:
				forward_best = jp
				forward_dist = dist
		
		else:
			if dist < back_dist:
				back_best = jp
				back_dist = dist
	
	if forward_best != null and (back_best == null or back_dist > forward_dist * 2):
		return forward_best

	return back_best

func get_dir(x):
	if x >= 0:
		return 1
	return -1

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
