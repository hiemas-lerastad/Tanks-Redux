extends Sprite2D;
class_name explosion;

@export_category("Settings")
@export var explosion_scale = Vector2(1,1);
@export var explosion_damage: int;
@export var exploision_time: float = 1.5;
@export var reduction_time: float = .25;
@export var explosion_area: Area2D;
@export var inner_explosion_radius: float = 20;
@export var outer_explosion_radius: float = 30;

var damaged_players: Array[Player];

func _ready():
	scale = Vector2(0,0)
	
	var tw: Tween = create_tween()
	tw.tween_property(self,"scale",explosion_scale,exploision_time)
	tw.tween_property(self,"scale",Vector2(0,0),.5)
	tw.tween_callback(queue_free)

	var timer: Timer = Timer.new()
	add_child(timer)
	timer.one_shot = true;
	timer.autostart = false;
	timer.wait_time = exploision_time;
	timer.timeout.connect(_trigger_carve)
	timer.start()

func _trigger_carve():
	Globals.level.square_manager.call_carve_around_point(global_position, inner_explosion_radius, outer_explosion_radius)

func check_players():
	for overlap in explosion_area.get_overlapping_bodies():
		if(overlap is Player):
			if(overlap not in damaged_players):
				damaged_players.append(overlap)
				overlap.health_component.take_damage(explosion_damage)

func _process(delta):
	check_players()
