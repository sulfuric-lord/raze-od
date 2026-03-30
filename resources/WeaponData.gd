extends Resource
class_name WeaponData
enum FireType {
	PROJECTILE,
	HITSCAN
}



@export var name: String
@export var projectile: PackedScene
@export var dmg_mult: float
@export var spread: float
@export var proj_count: int
@export var ammo: int
@export var reload: float
@export var fire_rate: float
@export var proj_speed_mult: float
@export var is_auto: bool
@export var sprite: Texture2D

@export var fire_type: FireType = FireType.PROJECTILE
@export var range: float = 2000.0
@export var tracer_scene: PackedScene
@export var tracer_damage: float
