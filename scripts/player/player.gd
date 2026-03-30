extends CharacterBody2D

@onready var movement := $Movement
@onready var dash := $dash

func _ready() -> void:
	add_to_group("entities")

func _physics_process(delta: float) -> void:
	
	var v := velocity
	v = movement.get_vel(delta, v)

	if dash.is_dashing():
		v = dash.get_vel_override()

	velocity = v
	move_and_slide()

func check_direction():
	var d := 0.0
	if Input.is_action_pressed("ui_left"):
		d -= 1.0
	elif Input.is_action_pressed("ui_right"):
		d += 1.0
	return d
