extends Node2D

@export var not_player: bool = true

@export var weapons : Array[WeaponData]
var idx : int = 0
var weapon_direction: Vector2 = Vector2.RIGHT
var fire_timer : float = 0.0

var ammo_list: Array[int] = []
var reload_timers: Array[float] = []
var is_reloading: Array[bool] = []
var displayable_ammo: String = ""

func _ready() -> void:
	for w in weapons:
		ammo_list.append(w.ammo)
		reload_timers.append(0.0)
		is_reloading.append(false)
	pass
		

func _process(delta: float) -> void:
	if not_player:
		return
	for i in range(weapons.size()):
		if Input.is_action_just_pressed("w_%d" % (i + 1)):
			switch(i)
	
	var w := weapons[idx]
	weapon_direction = (get_global_mouse_position() - global_position).normalized()
	var weapon_rotation = weapon_direction.angle()
		
	if w.is_auto:
		if Input.is_action_pressed("shoot") and fire_timer <= 0 and ammo_list[idx] > 0:
			shoot()
	else:
		if Input.is_action_just_pressed("shoot") and fire_timer <= 0 and ammo_list[idx] > 0:
			shoot()
	
	if Input.is_action_just_pressed("reload") and ammo_list[idx] != w.ammo:
		ammo_list[idx] = 0
		
	displayable_ammo = "%d / %d" % [ammo_list[idx], w.ammo]

func _physics_process(delta: float) -> void:
	var w := weapons[idx]

	if ammo_list[idx] <= 0 and not is_reloading[idx]:
		is_reloading[idx] = true
		reload_timers[idx] = w.reload

	if fire_timer > 0:
		fire_timer -= delta

	if is_reloading[idx]:
		reload_timers[idx] -= delta
		displayable_ammo = "Reloading..."
		
		if reload_timers[idx] <= 0:
			is_reloading[idx] = false
			ammo_list[idx] = w.ammo

func switch(new_idx: int):
	if new_idx == idx:
		return
	idx = new_idx
	fire_timer = 0

func shoot():
	
	var w := weapons[idx]

	for i in range(w.proj_count):
		var spread_rad = deg_to_rad(w.spread)
		var angle_offset = randf_range(-spread_rad, spread_rad)
		var dir = weapon_direction.rotated(angle_offset)
		
		if w.fire_type == w.FireType.PROJECTILE:
			var p = w.projectile.instantiate()
			p.direction = dir
			p.global_position = global_position
			
			
			p.speed = p.data.speed * w.proj_speed_mult
			p.damage = p.data.damage * w.dmg_mult
			get_tree().current_scene.add_child(p)
			
		else:
			shoot_hitscan(w, dir)
		
	ammo_list[idx] -= 1
	fire_timer = 1.0 / w.fire_rate
	
func shoot_hitscan(w, dir: Vector2):
	var from = global_position
	var to = from + w.range * dir
	
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [self]
	
	var result = space.intersect_ray(query)
	var hit_pos = to

	if result:
		var target = Utils.get_damageable(result.collider)
		if target:
			target.take_damage(w.tracer_damage * w.dmg_mult)
		hit_pos = result.position
	
	spawn_tracer(from, hit_pos, w)
	
func spawn_tracer(from: Vector2, to: Vector2, w):
	if w.tracer_scene == null:
		return
		
	var t = w.tracer_scene.instantiate()
	t.start = from
	t.end = to
	
	get_tree().current_scene.add_child(t)
	
func ai_shoot(dir: Vector2):
	weapon_direction = dir
	
	var w := weapons[idx]
	
	if ammo_list[idx] <= 0 and not is_reloading[idx]:
		is_reloading[idx] = true
		reload_timers[idx] = w.reload
		return
	
	if is_reloading[idx]:
		return
	
	if fire_timer <= 0 and ammo_list[idx] > 0:
		shoot()
