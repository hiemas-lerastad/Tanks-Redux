class_name Chunk;
extends Node2D;

@export_category("Nodes")
@export var static_body: StaticBody2D;

@export_category("Scenes")
@export var collision_polygon_scene: PackedScene;

var default_quadrant_polygon: Array = []

func _ready() -> void:
	init_chunk();

func init_chunk() -> void:
	if not multiplayer.is_server():
		return
	static_body.add_child(_new_collision_polygon(default_quadrant_polygon), true)

func reset_chunk() -> void:
	for collision_polygon in static_body.get_children():
		if multiplayer.is_server():
			collision_polygon.queue_free()
	init_chunk()

func carve(clipping_polygon: PackedVector2Array) -> void:
	if not multiplayer.is_server():
		return

	for colpol in static_body.get_children():
		var clipped_polygons = Polygons.clip(colpol.polygon, clipping_polygon)

		match clipped_polygons.size():
			0:
				colpol.queue_free()
			1:
				colpol.update_pol(clipped_polygons[0])
				print('here1')
			_:
				colpol.update_pol(clipped_polygons[0])
				print('here2')
				for i in range(clipped_polygons.size() - 1):
					static_body.add_child(_new_collision_polygon(clipped_polygons[i + 1]), true)

func _assign_polygons(polygons: Array) -> void:
	for child in static_body.get_children():
		if multiplayer.is_server():
			child.queue_free()
	for polygon in polygons:
		static_body.add_child(_new_collision_polygon(polygon), true)

func _new_collision_polygon(polygon) -> CollisionPolygon:
	var collision_polygon = collision_polygon_scene.instantiate()
	collision_polygon.polygon = polygon
	return collision_polygon
