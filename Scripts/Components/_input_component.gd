extends Node

signal begin_firing
signal end_firing
signal shot_fired(strength: int)

@export_category("Settings")
@export var controls: CharacterBody2D
@export var max_speed: float = 30.0
@export var fall_speed: float = 50.0

var is_firing: bool
var firing_tween: Tween

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
func movement_controls() -> void:
	''' take in the left/right direction, apply appropriate velocity + gravity'''
	
	if  multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		if not controls.is_multiplayer_authority():
			return;
	
		var input_direction = Input.get_axis("left","right")
		
		if(input_direction != 0 and !is_firing):
			controls.velocity.x = input_direction * max_speed
		else:
			controls.velocity.x = lerpf(controls.velocity.x,0,.2)

func turret_controls(d) -> void:
	if not controls.is_multiplayer_authority():
		return;

	var turret_direction = Input.get_axis("up","down")
	
	if(turret_direction != 0):
		controls.turret.rotation = lerp_angle(controls.turret.rotation, 1.55 * turret_direction, .5 *d)

func fire_controls() -> void:
	''' holding down fire button will cause a ui component to show, indicating the shot strength
	this strength will increase from 0 - 100 and back for as long as is held
	
	Once released the shot will be fired, once the last projectile has exploded the player will no longer be able to move
	and their turn will be over.
	 '''
	
	if not controls.is_multiplayer_authority():
		return;
	
	var trigger_fire: bool = Input.is_action_just_pressed("fire")
	var trigger_release: bool  = Input.is_action_just_released("fire")
	
	if(trigger_fire and !is_firing):
		#triggered fire and not already firing
		is_firing = true
		emit_signal("begin_firing")
	if(trigger_release and is_firing):
		#began firing and released
		is_firing = false
		emit_signal("shot_fired",controls.shoot_progress.value) # bind projectile shot to this
		emit_signal("end_firing")
		
		if Globals.player_turn + 1 < Globals.player_list.size():
			Globals.player_turn = Globals.player_turn + 1;
			Globals.set_player_turn.rpc(Globals.player_turn);
		else:
			Globals.player_turn = 0;
			Globals.set_player_turn.rpc(0);

func _begin_shooting_animation():
	firing_tween = create_tween()
	firing_tween.set_loops()
	firing_tween.tween_property(controls.shoot_progress, "value", 100, 1)
	firing_tween.tween_property(controls.shoot_progress, "value", 0, 1)

func _end_shooting_animation():
	firing_tween.kill()
	controls.shoot_progress.value = 0

func _process(delta) -> void:
	gravity()

	if Globals.player_turn == controls.id:
		movement_controls()
		turret_controls(delta)
		fire_controls()
