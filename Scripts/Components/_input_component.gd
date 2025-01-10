extends Node

@export_category("Settings")
@export var controls: CharacterBody2D
@export var max_speed: float = 15.0
@export var fall_speed: float = 29.8
var is_falling: bool

func gravity() -> void:
	''' applies gravity to characterbody2d controls accelerate if has been falling for x time '''
	
	if(!floor_check()):
		controls.velocity.y = fall_speed
	else:
		controls.velocity.y = 0

func floor_check() -> bool:
	return controls.is_on_floor()

func _process(delta) -> void:
	''' take in the left/right direction, apply appropriate velocity + gravity'''
	var input_direction = Input.get_axis("left","right")
	
	gravity()
	
	if(input_direction != 0):
		controls.velocity.x = input_direction * max_speed
	else:
		controls.velocity.x = lerpf(controls.velocity.x,0,.2)
