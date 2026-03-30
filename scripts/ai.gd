extends Node

@export var speed := 200.0
@export var jump_force := 1000.0
@export var gravity := 900.0

@export var think_delay := 0.2

@export var optimal_distance := 150.0
@export var distance_tolerance := 30.0

var body: CharacterBody2D
var weapon: Node
var team_node: Node

var target: Node2D = null
var think_timer := 0.0
var move_dir := 0

var reposition_dir := 0
var reposition_timer := 0.0

func _ready():
	body = get_parent()
	weapon = body.get_node("Weapon")
	team_node = body.get_node("Team")
	
	body.add_to_group("entities")


func _physics_process(delta):
	apply_gravity(delta)
	
	think_timer -= delta
	if think_timer <= 0:
		think()
		think_timer = think_delay
	
	act(delta)
	
	body.move_and_slide()


# 🧠 THINK (решения)
func think():
	target = find_target()
	
	if target == null:
		move_dir = 0
		return
	
	var dir = sign(target.global_position.x - body.global_position.x)
	move_dir = dir
	
	reposition_timer -= think_delay

	if reposition_timer <= 0:
		reposition_dir = (randi() % 2) * 2 - 1 # -1 или 1
		reposition_timer = randf_range(1.0, 2.0)


# 🚶 ACT (действия)
func act(delta):
	if target == null:
		return
	
	var to_target = target.global_position - body.global_position
	var dir = to_target.normalized()
	
	var dx = to_target.x
	var dist = abs(dx)
	
	var is_target_above = target.global_position.y < body.global_position.y - 80
	var can_jump = can_jump_to(target.global_position)
	
		# 👉 1. ПРЫЖОК — если можем, прыгаем сразу
	if is_target_above and can_jump and not has_ceiling_above():
		if body.is_on_floor():
			try_jump()
	
	# 👉 2. REPOSITION — если не можем прыгнуть
	elif is_target_above:
		if has_ceiling_above():
			if abs(dx) < 50:
				move_dir = randf() < 0.5 if -1 else 1
			else:
				move_dir = sign(dx)
			
	# 👉 3. ДИСТАНЦИЯ — если всё ок по высоте
	else:
		if dist > optimal_distance + distance_tolerance:
			move_dir = sign(dx)
		elif dist < optimal_distance - distance_tolerance:
			move_dir = -sign(dx)
		else:
			move_dir = 0
	
	# 👉 применяем движение
	body.velocity.x = move_dir * speed
	
	# 👉 стрельба
	if has_line_of_sight(target):
		weapon.ai_shoot(dir)

# 🔫 Проверка линии огня
func has_line_of_sight(t: Node2D) -> bool:
	var from = body.global_position
	var to = t.global_position
	
	var space = body.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [body]
	
	var result = space.intersect_ray(query)
	
	if result:
		var hit = result.collider
		
		while hit:
			if hit == t:
				return true
			hit = hit.get_parent()
	
	return false


# 🔍 Поиск цели
func find_target():
	var candidates = get_tree().get_nodes_in_group("entities")
	
	var best = null
	var best_dist = INF
	
	for c in candidates:
		if c == body:
			continue
		
		var c_team = c.get_node("Team").team
		var my_team = team_node.team
		
		if c_team == my_team:
			continue
		
		var dist = body.global_position.distance_to(c.global_position)
		
		if dist < best_dist:
			best = c
			best_dist = dist
	
	return best



# 🧗 Прыжок
func try_jump():
	if body.is_on_floor():
		body.velocity.y = -jump_force


# 🌍 Гравитация
func apply_gravity(delta):
	if not body.is_on_floor():
		body.velocity.y += gravity * delta

func can_jump_to(target_pos: Vector2) -> bool:
	var sim_pos = body.global_position
	
	# направление к цели
	var dir_x = sign(target_pos.x - sim_pos.x)
	
	# начальная скорость (примерно как у тебя)
	var vel = Vector2(dir_x * speed, -jump_force)
	
	var dt = 0.1
	var steps = 20
	
	var space = body.get_world_2d().direct_space_state
	
	for i in range(steps):
		# обновляем позицию
		sim_pos += vel * dt
		
		# гравитация
		vel.y += gravity * dt
		
		# 👉 проверяем землю под точкой
		var from = sim_pos
		var to = sim_pos + Vector2(0, 20)
		
		var query = PhysicsRayQueryParameters2D.create(from, to)
		query.exclude = [body]
		
		var result = space.intersect_ray(query)
		
		if result:
			# 👉 если близко к цели по высоте — считаем успех
			if abs(sim_pos.y - target_pos.y) < 50:
				return true
	
	return false


func has_ceiling_above() -> bool:
	var from = body.global_position + Vector2(0, -10)
	var to = from + Vector2(0, -40)
	
	var space = body.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [body]
	
	var result = space.intersect_ray(query)
	
	# 👉 если потолок СЛИШКОМ близко — плохо
	if result:
		var dist = from.distance_to(result.position)
		return dist < 20
	
	return false
