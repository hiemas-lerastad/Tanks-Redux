class_name Terrain;
extends Node2D;

@export_category("Nodes")
@export var chunks: Node2D;
@export var carve_shape: Polygon2D;

@export_category("Settings")
@export var chunk_size: int = 100;
@export var carve_radius: int = 40;
@export var min_movement_update: int = 5;

@export_category("Scenes")
@export var chunk_scene: PackedScene;

var chunk_grid_size: Vector2;
var chunk_grid: Array = [];
var screen_size: Vector2;

# Testing vars
var old_mouse_pos: Vector2 = Vector2();
var mouse_pos: Vector2 = Vector2();

func _ready() -> void:
	screen_size = get_viewport().content_scale_size;
	chunk_grid_size = Vector2(ceil(screen_size.x/chunk_size),ceil((screen_size.y/2)/chunk_size));
	_spawn_chunks();
	#	test
	_make_mouse_circle();
	
func _process(_delta) -> void:
	if Input.is_action_pressed("click_left"):
		if old_mouse_pos.distance_to(mouse_pos) > min_movement_update:
			_carve()
			old_mouse_pos = mouse_pos

func _input(event) -> void:
	if event is InputEventMouseMotion:
		mouse_pos = get_global_mouse_position()
		carve_shape.position = mouse_pos
		queue_redraw()

func _carve() -> void:
	var mouse_polygon = Transform2D(0, mouse_pos) * (carve_shape.polygon)

	var four_chunks = _get_affected_chunks(mouse_pos)
	for chunk in four_chunks:
		chunk.carve(mouse_polygon)

func _spawn_chunks() -> void:
	for i in range(chunk_grid_size.x):
		chunk_grid.push_back([])
		for j in range(chunk_grid_size.y):
			var chunk = chunk_scene.instantiate()
			chunk.default_quadrant_polygon = [
				Vector2(chunk_size*i,chunk_size*j + (screen_size.y/2)),
				Vector2(chunk_size*(i+1),chunk_size*j + (screen_size.y/2)),
				Vector2(chunk_size*(i+1),chunk_size*(j+1) + (screen_size.y/2)),
				Vector2(chunk_size*i,chunk_size*(j+1) + (screen_size.y/2))
			]
			chunk_grid[-1].push_back(chunk)
			chunks.add_child(chunk)

func _get_affected_chunks(pos) -> Array:
	var affected_chunks = []
	var half_diag = sqrt(2) * chunk_size/2
	for chunk in chunks.get_children():
		var chunk_top_left = chunk.default_quadrant_polygon[0]
		var chunk_center = chunk_top_left + Vector2(chunk_size, chunk_size)/2
		if chunk_center.distance_to(pos) <= carve_radius + half_diag:
			affected_chunks.push_back(chunk)
	return affected_chunks

func _make_mouse_circle() -> void:
	var nb_points = 15
	var pol = []
	for i in range(nb_points):
		var angle = lerp(-PI, PI, float(i)/nb_points)
		pol.push_back(mouse_pos + Vector2(cos(angle), sin(angle)) * carve_radius)
	carve_shape.polygon = pol
