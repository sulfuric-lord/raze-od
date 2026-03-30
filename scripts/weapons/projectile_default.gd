extends Area2D

@export var data: ProjectileData

var direction := Vector2.RIGHT
var damage : float
var speed : float
var time_left = 0.0

func _ready():
	time_left = data.lifetime
	$Sprite2D.texture = data.sprite

func _physics_process(delta):
	direction = direction.normalized()
	global_position += direction * speed * delta
	time_left -= delta
	if time_left <= 0:
		queue_free()
