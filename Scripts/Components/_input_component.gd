extends Node

@export_category("Settings")
@export var controls: CharacterBody2D
@export var max_speed: float = 50.0
@export var fall_speed: float = 29.8

var is_falling: bool
var input_direction: float;

func gravity() -> void:
	if not controls.is_multiplayer_authority():
		return;
	''' applies gravity to characterbody2d controls accelerate if has been falling for x time '''
	
	if(!floor_check()):
		controls.velocity.y = fall_speed
	else:
		controls.velocity.y = 0

func floor_check() -> bool:
	return controls.is_on_floor()

func _process(delta) -> void:
	if  multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		if not controls.is_multiplayer_authority():
			return;

		''' take in the left/right direction, apply appropriate velocity + gravity'''
		input_direction = Input.get_axis("left", "right")
		
		if(input_direction != 0):
			controls.velocity.x = input_direction * max_speed
		else:
			controls.velocity.x = lerpf(controls.velocity.x,0,.2)
				
		gravity()
