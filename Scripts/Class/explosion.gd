extends Sprite2D
class_name explosion


@export_category("Settings")
@export var explosion_scale = Vector2(1,1)
@export var exploision_time: float = 1.5
@export var reduction_time: float = .25
@export var inner_explosion_radius: float = 20;
@export var outer_explosion_radius: float = 30;

func _ready():
	scale = Vector2(0,0)
	
	var tw: Tween = create_tween()
	tw.tween_property(self,"scale",explosion_scale,exploision_time)
	tw.tween_property(self,"scale",Vector2(0,0),.5)
	
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.one_shot = true;
	timer.autostart = false;
	timer.wait_time = exploision_time;
	timer.timeout.connect(_trigger_carve)
	timer.start()

func _trigger_carve():
	Globals.level.square_manager.call_carve_around_point(global_position, inner_explosion_radius, outer_explosion_radius)
