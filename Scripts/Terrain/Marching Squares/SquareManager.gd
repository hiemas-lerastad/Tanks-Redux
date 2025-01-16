class_name SquareManager;
extends Node2D;

@export_category("Settings")
@export var grid_scale: int = 10;
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

var matrix: Array[Array] = [];
var squares_matrix: Array[Array] = [[]];

var configurations: Dictionary = {
	0: {
		"points": [],
		"skews": {}
	},
	bin2int("1111"): {
		"points": ["a", "b", "c", "d"],
		"skews": {}
	},
	
	# 1 Dot
	bin2int("0001"): {
		"points":  ["a", "e", "h"],
		"skews": {
			"e": "a",
			"h": "a",
		}
	},
	bin2int("0010"): {
		"points":  ["e", "b", "f"],
		"skews": {
			"e": "b",
			"f": "b",
		}
	},
	bin2int("0100"): {
		"points":  ["f", "c", "g"],
		"skews": {
			"f": "c",
			"g": "c",
		}
	},
	bin2int("1000"): {
		"points":  ["g", "d", "h"],
		"skews": {
			"g": "d",
			"h": "d",
		}
	},
	
	# 2 Dots
	bin2int("0011"): {
		"points":  ["a", "b", "f", "h"],
		"skews": {
			"h": "a",
			"f": "b",
		}
	},
	bin2int("0110"): {
		"points":  ["e", "b", "c", "g"],
		"skews": {
			"e": "b",
			"g": "c",
		}
	},
	bin2int("1100"): {
		"points":  ["h", "f", "c", "d"],
		"skews": {
			"h": "d",
			"f": "c",
		}
	},
	bin2int("1001"): {
		"points":  ["a", "e", "g", "d"],
		"skews": {
			"e": "a",
			"g": "d",
		}
	},
	
	bin2int("0101"): {
		"points":  ["h", "a", "e", "f", "c", "g"],
		"skews": {
			"h": "a",
			"e": "a",
			"f": "c",
			"g": "c",
		}
	},
	bin2int("1010"): {
		"points":  ["h", "e", "b", "f", "g", "d"],
		"skews": {
			"e": "b",
			"f": "b",
			"h": "d",
			"g": "d",
		}
	},
	
	# 3 Dots
	bin2int("0111"): {
		"points":  ["h", "a", "b", "c", "g"],
		"skews": {
			"h": "a",
			"g": "c",
		}
	},
	bin2int("1110"): {
		"points":  ["h", "e", "b", "c", "d"],
		"skews": {
			"h": "d",
			"e": "b",
		}
	},
	bin2int("1101"): {
		"points":  ["a", "e", "f", "c", "d"],
		"skews": {
			"e": "a",
			"f": "c",
		}
	},
	bin2int("1011"): {
		"points":  ["a", "b", "f", "g", "d"],
		"skews": {
			"f": "b",
			"g": "d",
		}
	}
}

func _ready() -> void:
	size_width = (get_viewport().content_scale_size.x / grid_scale) + 1;
	size_height = (get_viewport().content_scale_size.y / grid_scale) + 2;

	randomize();
	
	noise = FastNoiseLite.new();
	noise.noise_type = FastNoiseLite.TYPE_PERLIN;
	noise.frequency = 0.02
	noise.seed = randi();
	
	set_initial_grid()

	for x in range(0, matrix.size() - 1):
		for y in range(0, matrix[x].size() - 1):
			var values: Dictionary = {
				"a": matrix[x][y],
				"b": matrix[x + 1][y],
				"c": matrix[x + 1][y + 1],
				"d": matrix[x][y + 1],
			}
			
			var a: Vector2 = (Vector2(x, y) * grid_scale) - Vector2(0.1, 0.1);
			var b: Vector2 = (Vector2(x + 1, y) * grid_scale) - Vector2(0, 0.1);
			var c: Vector2 = Vector2(x + 1, y + 1) * grid_scale;
			var d: Vector2 = (Vector2(x, y + 1) * grid_scale) - Vector2(0.1, 0);
			
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
			
			var configuration: int = ceil(values["a"]) * pow(2,0) + ceil(values["b"]) * pow(2,1) + ceil(values["c"]) * pow(2, 2) + ceil(values["d"]) * pow(2, 3);
			var points_to_connect: Array = configurations[configuration].points;
			var polygon_points: Array[Vector2];
			
			for skew_key in configurations[configuration].skews:
				var skew_value_key = configurations[configuration].skews[skew_key]
				var point_to_skew = points_dictionary[skew_key];
				var point_to_skew_by = points_dictionary[skew_value_key];
				
				if point_to_skew_by < point_to_skew:
					point_to_skew = point_to_skew_by + ((point_to_skew - point_to_skew_by) * Vector2(values[skew_value_key], values[skew_value_key]))
				else:
					point_to_skew = point_to_skew_by - ((point_to_skew_by - point_to_skew) * Vector2(values[skew_value_key], values[skew_value_key]))
				
				points_dictionary[skew_key] = point_to_skew;
				
				
			for point in points_to_connect:
				polygon_points.append(points_dictionary[point])
			
			var square: Square = square_scene.instantiate();
			square.position = Vector2(x, y) / (grid_scale);
			
			square.visible_polygon.polygon = polygon_points;
			square.collision_polygon.polygon = polygon_points;
			add_child(square);
			
			if not x == 0:
				squares_matrix.append([]);
			elif squares_matrix[x]:
				squares_matrix.append([]);
			if squares_matrix[x].size() <= y:
				squares_matrix[x].append(square);
			else:
				squares_matrix[x][y] = square;


func set_initial_grid() -> void:	
	matrix.clear()
	matrix = []
	for x in range(size_width):
		matrix.append([])
		matrix[x].resize(size_height)
		for y in range(size_height):
			var noiseValue = noise.get_noise_2d(x, 1);

			if ((noiseValue + 1) / 2) * size_height < y:
				matrix[x][y] = 1;
			elif ((noiseValue + 1) / 2) * size_height < y + 1:
				matrix[x][y] = (y + 1) - (((noiseValue + 1) / 2) * size_height)
			else:
				matrix[x][y] = 0;

#func _draw() -> void:
	## Dots
	#for x in range(matrix.size()):
		#for y in range(matrix[x].size()):
			#if matrix[x][y] == 0:
				#draw_circle(Vector2(x, y) * (grid_scale), dot_size, dot_color_empty);
			#else:
				#draw_circle(Vector2(x, y) * (grid_scale), dot_size, dot_color_filled);

func update_polygons() -> void:
	for x in range(0, matrix.size() - 1):
		for y in range(0, matrix[x].size() - 1):
			var values: Dictionary = {
				"a": matrix[x][y],
				"b": matrix[x + 1][y],
				"c": matrix[x + 1][y + 1],
				"d": matrix[x][y + 1],
			}
			
			var a: Vector2 = (Vector2(x, y) * grid_scale) - Vector2(0.1, 0.1);
			var b: Vector2 = (Vector2(x + 1, y) * grid_scale) - Vector2(0, 0.1);
			var c: Vector2 = Vector2(x + 1, y + 1) * grid_scale;
			var d: Vector2 = (Vector2(x, y + 1) * grid_scale) - Vector2(0.1, 0);
			
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
			
			var configuration: int = ceil(values["a"]) * pow(2,0) + ceil(values["b"]) * pow(2,1) + ceil(values["c"]) * pow(2, 2) + ceil(values["d"]) * pow(2, 3);
			var points_to_connect: Array = configurations[configuration].points;
			var polygon_points: Array[Vector2];
			
			for skew_key in configurations[configuration].skews:
				var skew_value_key = configurations[configuration].skews[skew_key]
				var point_to_skew = points_dictionary[skew_key];
				var point_to_skew_by = points_dictionary[skew_value_key];
				
				if point_to_skew_by < point_to_skew:
					point_to_skew = point_to_skew_by + ((point_to_skew - point_to_skew_by) * Vector2(values[skew_value_key], values[skew_value_key]))
				else:
					point_to_skew = point_to_skew_by - ((point_to_skew_by - point_to_skew) * Vector2(values[skew_value_key], values[skew_value_key]))
				
				points_dictionary[skew_key] = point_to_skew;
				
			for point in points_to_connect:
				polygon_points.append(points_dictionary[point])
			
			var square: Square = squares_matrix[x][y];
			square.position = Vector2(x, y) / (grid_scale);
			
			square.visible_polygon.polygon = polygon_points;
			square.collision_polygon.polygon = polygon_points;

func bin2int(bin_str) -> int:
	var out: int = 0;

	for c in bin_str:
		out = (out << 1) + int(c == "1");

	return out;
