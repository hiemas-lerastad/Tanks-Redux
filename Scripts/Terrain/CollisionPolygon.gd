class_name CollisionPolygon;
extends CollisionPolygon2D;

@export_category("Nodes")
@export var polygon_node: Polygon2D;

func _ready() -> void:
	polygon_node.polygon = polygon;

func update_pol(polygon_points: PackedVector2Array) -> void:
	polygon = polygon_points
	polygon_node.polygon = polygon
