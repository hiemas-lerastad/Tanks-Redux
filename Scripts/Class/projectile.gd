extends CharacterBody2D
class_name projectile

var explosion_size: float # size to grow the explosion + carve to (currently only makes sense in circle explosion)

var initial_strength: int
#var initial_direction: Vector2

func _explode() ->void:
	''' swap sprite to appropriate explosion type, create a temporary area2d to scan for players without 
	colliding with them, trigger the growing + culling'''
	
	pass

func _wind_resistance() -> void:
	''' placeholder until wind has been added'''
	
	pass

func _drag(d) -> void:
	''' air drag as the projectile flies it should begin to slow down regardless of wind'''
	velocity.x = lerpf(velocity.x,0,.25 *d)
	

func _gravity(d) -> void:
	velocity.y += 2 #* d 

func _physics_process(delta):
	_gravity(delta)
	_drag(delta)
	var c: KinematicCollision2D = move_and_collide(velocity*delta)
	if(c != null):
		pass

func _ready():
	''' split second of non-collision to allow for touching shooter, other spawned projectiles, etc.'''
	
	velocity = -transform.y * initial_strength
	
