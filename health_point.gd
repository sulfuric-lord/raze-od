extends Area2D

@export var cooldown := 8.0
@onready var sprite = $Sprite2D

var cd_timer := 0.0
var active := true

func _ready():
	add_to_group("heal_points")
	connect("body_entered", _on_body_entered)

func _physics_process(delta):
	if not active:
		cd_timer -= delta
		if cd_timer <= 0:
			active = true
			sprite.show()


func _on_body_entered(body):
	if not active:
		return
	sprite.hide()
	
	var target = Utils.get_healable(body)
	if target:
		var heal_amount = target.maxHp * 0.5
		target.heal(heal_amount)
		
		active = false
		cd_timer = cooldown
