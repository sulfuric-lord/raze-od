extends Node2D

# MOVEMENT_STATS
@export var speed: float = 300.0
@export var gravity: float = 2000.0
@export var jump_speed: float = 1000.0
@export var max_jumps: int = 2

# DASH_STATS
var dash_time: float = 0.06
var dash_speed: float = 2000.0
@export var dash_cooldown: float = 1.2
