extends Sprite2D
class_name explosion


@export_category("Settings")
@export var explosion_scale = Vector2(1,1)
@export var exploision_time: float = 1.5
@export var reduction_time: float = .25
func _ready():
	scale = Vector2(0,0)
	
	var tw: Tween = create_tween()
	tw.tween_property(self,"scale",explosion_scale,exploision_time)
	tw.tween_property(self,"scale",Vector2(0,0),.5)
