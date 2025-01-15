class_name SquareManager;
extends Node2D;

@export_category("Settings")
@export var grid_scale: int = 25;
@export var dot_size: float = 2.5;
@export var size_width: int;
@export var size_height: int;

var noise: FastNoiseLite;

@export_category("Colours")
@export var dot_color_filled: Color;
@export var dot_color_empty: Color;
@export var line_color: Color;

@export_category("Scenes")
@export var square_scene: PackedScene;

var matrix: Array = [];

var configurations: Dictionary = {
	0: [],
	bin2int("1111"): {
		"points": ["a", "b", "c", "d"],
		"skews": []
	},
	
	# 1 Dot
	bin2int("0001"): ["a", "e", "h"],
	bin2int("0010"): ["e", "b", "f"],
	bin2int("0100"): ["f", "c", "g"],
	bin2int("1000"): ["g", "d", "h"],
	
	# 2 Dots
	bin2int("0011"): ["a", "b", "f", "h"],
	bin2int("0110"): ["e", "b", "c", "g"],
	bin2int("1100"): ["h", "f", "c", "d"],
	bin2int("1001"): ["a", "e", "g", "d"],
	
	bin2int("0101"): ["h", "a", "e", "f", "c", "g"],
	bin2int("1010"): ["h", "e", "b", "f", "g", "d"],
	
	# 3 Dots
	bin2int("0111"): ["h", "a", "b", "c", "g"],
	bin2int("1110"): ["h", "e", "b", "c", "d"],
	bin2int("1101"): ["a", "e", "f", "c", "d"],
	bin2int("1011"): ["a", "b", "f", "g", "d"]
}

func _ready() -> void:
	size_width = (get_viewport().content_scale_size.x / grid_scale) + 1;
	size_height = (get_viewport().content_scale_size.y / grid_scale) + 1;
	print(size_width)
	randomize();
	
	noise = FastNoiseLite.new();
	noise.noise_type = FastNoiseLite.TYPE_PERLIN;
	noise.seed = randi();
	
	update_grid_values()

	for x in range(0, matrix.size() - 1):
		for y in range(0, matrix[x].size() - 1):
			var a_value: float = matrix[x][y];
			var b_value: float = matrix[x + 1][y];
			var c_value: float = matrix[x + 1][y + 1];
			var d_value: float = matrix[x][y + 1];
			
			var a: Vector2 = Vector2(x, y) * grid_scale;
			var b: Vector2 = Vector2(x + 1, y) * grid_scale;
			var c: Vector2 = Vector2(x + 1, y + 1) * grid_scale;
			var d: Vector2 = Vector2(x, y + 1) * grid_scale;
			
			var e = ((b - a) / 2) + a;
			var f = ((c - b) / 2) + b;
			var g = ((d - c) / 2) + c;
			var h = ((d - a) / 2) + a;
			
			var points_dictionary: Dictionary = {
				"a": a,
				"b": b,
				"c": c,
				"d": d,
				"e": e,
				"f": f,
				"g": g,
				"h": h
			}
			
			var configuration: int = a_value * pow(2,0) + b_value * pow(2,1) + c_value * pow(2, 2) + d_value * pow(2, 3);
			var points_to_connect: Array = configurations[configuration];
			print('------')
			var polygon_points: Array[Vector2];
			print(points_to_connect)
			for point in points_to_connect:
				polygon_points.append(points_dictionary[point])
			
			var square: Square = square_scene.instantiate();
			square.position = Vector2(x, y) / (grid_scale);
			#square.visible_polygon.polygon = [square.position, square.position + Vector2(grid_scale, 0), square.position + Vector2(grid_scale, grid_scale), square.position + Vector2(0, grid_scale)]
			#square.collision_polygon.polygon = [square.position, square.position + Vector2(grid_scale, 0), square.position + Vector2(grid_scale, grid_scale), square.position + Vector2(0, grid_scale)]
			square.visible_polygon.polygon = polygon_points;
			square.collision_polygon.polygon = polygon_points;
			add_child(square)

func update_grid_values() -> void:	
	matrix.clear()
	matrix = []
	for x in range(size_width):
		matrix.append([])
		matrix[x].resize(size_height)
		
		for y in range(size_height):
			var noiseValue = noise.get_noise_2d(x, y);
			if noiseValue > 0:
				matrix[x][y] = 1;
			else:
				matrix[x][y] = 0;

func _draw() -> void:
	# Dots
	for x in range(matrix.size()):
		for y in range(matrix[x].size()):
			if matrix[x][y] == 0:
				draw_circle(Vector2(x, y) * (grid_scale), dot_size, dot_color_empty);
			else:
				draw_circle(Vector2(x, y) * (grid_scale), dot_size, dot_color_filled);

func bin2int(bin_str) -> int:
	var out: int = 0;

	for c in bin_str:
		out = (out << 1) + int(c == "1");

	return out;
