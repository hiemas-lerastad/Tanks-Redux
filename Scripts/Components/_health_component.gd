extends Node

@export_category("Settings")
@export var parent_tank: CharacterBody2D
@export var initial_max_health: int = 100
@export var death_explosion: PackedScene
var current_health: int

func explode() ->void:
	'''tank explodes on death, '''
	parent_tank._knocked_out()
	if not multiplayer.is_server():
		return

	if(death_explosion != null):
		var explosion_clone: explosion = death_explosion.instantiate()
		explosion_clone.global_position = parent_tank.global_position
		add_sibling(explosion_clone, true)
		

func take_damage(damage: int):
	current_health -= damage
	if(current_health <= 0):
		explode()
	
func _ready():
	current_health = initial_max_health
