extends Node2D

@onready var line: Line2D = $Line2D

var start: Vector2
var end: Vector2

var speed := 7000.0
var trail_length_px := 150.0 
var t := 0.0

func _process(delta):
	modulate.a = clamp(1.0 - t, 0.0, 1.0)
	var distance = start.distance_to(end)
	var duration = max(distance / speed, 0.02)
	
	t += delta / duration
	var trail_length = min(trail_length_px / distance, 1.0)

	var t_start: float
	var t_end: float

	if t < trail_length:
		t_start = 0.0
		t_end = t
	else:
		t_start = t - trail_length
		t_end = t

	t_end = min(t_end, 1.0)

	var from = start.lerp(end, t_start)
	var to = start.lerp(end, t_end)

	line.points = [from, to]
	
	if distance < trail_length_px:
		line.points = [start, end]
		
		t += delta * 5.0
		
	if t >= 1.0:
		queue_free()
