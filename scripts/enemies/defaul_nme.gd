extends CharacterBody2D

enum State {
	CHASE,
	FIRE,
	RETREAT
}

var current_state = State.CHASE

var jps := []
@export var speed : float = 350.0
@export var jump_vel : float = 800.0

var current_target = null
var current_jp = null
var is_jumping := false
var retarget_timer := 0.0
@export var retarget_time := 5.0

var current_heal_point = null
@export var retreat_hp_threshold := 0.3

var to_target := Vector2.ZERO
var distance_to_target := INF

var same_level := false
var target_above := false
var target_below := false

@export var gravity := 1000.0
@onready var weapon = $Weapon
@export var maxHp : float
var hp : float

var shoot_decision_timer := 0.0
var wants_to_shoot := false

@export var shoot_decision_interval_min := 0.3
@export var shoot_decision_interval_max := 1.2
@export var shoot_chance := 0.6

func _ready():
	hp = maxHp
	jps = get_jps()
	add_to_group("entities")
	
func _physics_process(delta):
	think(delta)
	
	match current_state:
		State.CHASE:
			state_chase(delta)
		State.FIRE:
			state_fire(delta)
		State.RETREAT:
			state_retreat(delta)
	
	apply_gravity(delta)
	
	if is_on_floor():
		is_jumping = false
	
	move_and_slide()

func think(delta):
	retarget_timer -= delta
	var old_target = current_target
	
	var hp_ratio : float = hp / maxHp
	if hp_ratio <= retreat_hp_threshold:
		current_heal_point = find_heal_point()
		if current_heal_point != null:
			current_state = State.RETREAT
			return
	else:
		current_heal_point = null
	
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
	
	to_target = current_target.global_position - global_position
	distance_to_target = to_target.length()
	
	same_level = abs(to_target.y) <= 40
	target_above = to_target.y < -40
	target_below = to_target.y > 40
	
	if target_above:
		current_jp = find_jp_same_level()
	else:
		current_jp = null
	
	if same_level and distance_to_target <= 50:
		current_state = State.FIRE
	else:
		current_state = State.CHASE
		
	shoot_decision_timer -= delta

	if shoot_decision_timer <= 0:
		shoot_decision_timer = randf_range(shoot_decision_interval_min, shoot_decision_interval_max)
		wants_to_shoot = randf() < shoot_chance

func state_chase(delta):
	if current_target == null:
		velocity.x = 0
		return
	
	if is_jumping:
		return
	
	if same_level:
		var dir = sign(to_target.x)
		velocity.x = dir * speed
		if wants_to_shoot:
			weapon.ai_shoot(to_target)
		return
	
	if target_above:
		if current_jp == null:
			velocity.x = 0
			return
		
		var to_jp = current_jp.global_position - global_position
		var dir = sign(to_jp.x)
		
		velocity.x = dir * speed
		
		if abs(to_jp.x) <= 50:
			velocity.y = -jump_vel
			is_jumping = true
			current_jp = null
		
		return
	
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

func state_retreat(delta):
	if current_heal_point == null:
		current_state = State.CHASE
		return
	
	var to_heal = current_heal_point.global_position - global_position
	var same_level = abs(to_heal.y) <= 40
	var target_above = to_heal.y < -40
	var target_below = to_heal.y > 40
	
	if is_jumping:
		return
	
	if same_level:
		velocity.x = sign(to_heal.x) * speed
		return
	
	if target_above:
		var jp = find_jp_same_level()
		if jp == null:
			velocity.x = 0
			return
		
		var to_jp = jp.global_position - global_position
		velocity.x = sign(to_jp.x) * speed
		
		if abs(to_jp.x) <= 50:
			velocity.y = -jump_vel
			is_jumping = true
		
		return
	
	if target_below:
		var center_x = 0
		velocity.x = sign(center_x - global_position.x) * speed

func get_jps():
	return get_tree().get_nodes_in_group("jump_points")

func get_active_heal_points():
	var result := []
	
	for h in get_tree().get_nodes_in_group("heal_points"):
		if h.active:
			result.append(h)
	
	return result
	
func find_heal_point():
	var best = null
	var best_dist = INF
	
	for h in get_active_heal_points():
		var dist = global_position.distance_to(h.global_position)
		if dist < best_dist:
			best = h
			best_dist = dist
	
	return best

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
	var forward_correct = null
	var forward_correct_dist = INF

	var forward_wrong = null
	var forward_wrong_dist = INF

	var back_correct = null
	var back_correct_dist = INF

	var back_wrong = null
	var back_wrong_dist = INF
	
	var to_target = current_target.global_position - global_position
	var target_dir = get_dir(to_target.x)
	
	for jp in get_jps():
		if abs(jp.global_position.y - global_position.y) > 40:
			continue

		var to_jp = jp.global_position - global_position
		var dist = to_jp.length()
		var jp_dir = get_dir(to_jp.x)
		var is_forward = jp_dir == target_dir
		var is_correct = sign(jp.jump_direction.x) == target_dir
		
		if is_forward:
			if is_correct:
				if dist < forward_correct_dist:
					forward_correct = jp
					forward_correct_dist = dist
			else:
				if dist < forward_wrong_dist:
					forward_wrong = jp
					forward_wrong_dist = dist
		else:
			if is_correct:
				if dist < back_correct_dist:
					back_correct = jp
					back_correct_dist = dist
			else:
				if dist < back_wrong_dist:
					back_wrong = jp
					back_wrong_dist = dist
	
	if forward_correct != null:
		return forward_correct

	if forward_wrong != null:
		return forward_wrong

	if back_correct != null:
		return back_correct

	return back_wrong

func get_dir(x):
	if x >= 0:
		return 1
	return -1

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func take_damage(amount: float):
	hp -= amount
	
	if hp <= 0:
		die()

func die():
	queue_free()

func heal(amount: float):
	hp += amount
	hp = clamp(hp, 0, maxHp)
