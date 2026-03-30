extends CharacterBody2D

var jps := []
@export var speed : float = 400.0
@export var jump_vel : float = 400.0

var current_target = null
var current_jp = null
var is_jumping := false
var retarget_timer := 0.0
@export var retarget_time := 5.0

@export var gravity := 900.0

func _ready():
	jps = get_jps()
	add_to_group("entities")
	
func _physics_process(delta):
	think(delta)
	state_chase(delta)
	apply_gravity(delta)
	move_and_slide()

func think(delta):
	retarget_timer -= delta
	var old_target = current_target
	
	if retarget_timer <= 0:
		var enemies = get_enemies()
		current_target = find_enemy(enemies)
		retarget_timer = retarget_time
		
		if current_target != old_target:
			current_jp = null
			
	if current_target == null:
		current_jp = null

func state_chase(delta):
	if current_target == null:
		velocity.x = 0
		return
	
	var to_target = current_target.global_position - global_position
	var dir = sign(to_target.x)
	
	# обычное движение к цели
	velocity.x = dir * speed
	
	# если цель выше — просто идём, jump point сам сработает
	# можно оставить лёгкую коррекцию:
	if to_target.y < -20 and current_jp != null:
		var to_jp = current_jp.global_position - global_position
		var jp_dir = sign(to_jp.x)
		
		if jp_dir != 0:
			velocity.x = jp_dir * speed

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

func find_jp():
	var best = null
	var best_dist = INF
	
	for jp in jps:
		var dist = global_position.distance_to(jp.global_position)
		if dist < best_dist:
			best = jp
			best_dist = dist
	
	return best

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func use_jump_point(jp):
	# можно добавить проверку цели (чтобы не прыгал просто так)
	if current_target == null:
		return
	
	var to_target = current_target.global_position - global_position
	
	# прыгаем только если цель реально выше
	if to_target.y > -20:
		return
	
	velocity.x = jp.jump_direction.x * speed
	velocity.y = jp.jump_direction.y * jp.jump_force
	
	is_jumping = true
	current_jp = null
