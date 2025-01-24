class_name Level;
extends Node2D;

@export_category("Nodes")
@export var player_container: Node2D;
@export var square_manager: SquareManager;
@export var carve_shape: Polygon2D;
@export var projectile_container: Node2D;

@export_category("Scenes")
@export var player_scene: PackedScene;

@export_category("Variables")
@export var seed: int;

var mouse_pos: Vector2 = Vector2();
var old_mouse_pos: Vector2 = Vector2();

func _ready() -> void:
	if multiplayer.is_server():
		randomize()
		var rng = RandomNumberGenerator.new()
		seed = rng.get_seed();
	#_make_mouse_circle()
	square_manager.init_terrain()
	
	Globals.projectile_container = projectile_container;
	Globals.level = self;

func add_players(player_list: Array) -> void:
	if multiplayer.is_server():
		for index in range(0, player_list.size()):
			var player: int = player_list[index].id;
			var player_instance: Player = player_scene.instantiate();
			var multiplayer_id: int = player_list[index].multiplayer_id;

			player_instance.name = str(player);
			player_instance.id = player;
			player_instance.multiplayer_id = multiplayer_id;
			player_container.add_child(player_instance, true);
			
			setup_player.rpc_id(multiplayer_id, player, index);
		
@rpc("call_local", "reliable")
func setup_player(player: int, index: int) -> void:
	if player_container.get_node_or_null(str(player)):
		var player_instance: Player = player_container.get_node_or_null(str(player));

		player_instance.position = Vector2(player_instance.position.x + (index * 200), player_instance.position.y);

#func _process(_delta) -> void:
	#if Input.is_action_pressed("click_left"):
		#if old_mouse_pos.distance_to(mouse_pos) > 5:
			#square_manager.call_carve_around_point(mouse_pos, 40, 50);
			#old_mouse_pos = mouse_pos;

func _input(event) -> void:
	if event is InputEventMouseMotion:
		mouse_pos = get_global_mouse_position();
		carve_shape.position = mouse_pos;

#func _make_mouse_circle() -> void:
	#var nb_points = 15
	#var pol = []
	#for i in range(nb_points):
		#var angle = lerp(-PI, PI, float(i)/nb_points)
		#pol.push_back(mouse_pos + Vector2(cos(angle), sin(angle)) * 40)
	#carve_shape.polygon = pol
