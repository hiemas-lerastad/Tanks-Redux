extends Node

@export_category("Settings")
@export var shoot_point: Node2D
@export var parent_tank: CharacterBody2D

#var selected_projectile: projectile
@export var projectile_scene: PackedScene
func _fire(shot_strength: int) -> void:
	if multiplayer.is_server():
		var projectile_clone: projectile = projectile_scene.instantiate()
		projectile_clone.global_position = shoot_point.global_position
		projectile_clone.rotation = parent_tank.turret.rotation
		projectile_clone.initial_strength = shot_strength * 3
		Globals.projectile_container.add_child(projectile_clone, true)
	else:
		_fire_server.rpc_id(1, shot_strength)
	
@rpc('call_local', 'reliable')
func _fire_server(shot_strength: int) -> void:
	var projectile_clone: projectile = projectile_scene.instantiate()
	projectile_clone.global_position = shoot_point.global_position
	projectile_clone.rotation = parent_tank.turret.rotation
	projectile_clone.initial_strength = shot_strength * 3
	Globals.projectile_container.add_child(projectile_clone, true)
