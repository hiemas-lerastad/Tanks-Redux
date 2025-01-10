class_name Polygons

static func resolve_holes(polygons: Array) -> Array:
	if not has_hole(polygons):
		return polygons
	
	var results = []
	var grouped_polygons = _group_for_holes(polygons)
	for polygon_group in grouped_polygons:
		var polygon = polygon_group["outer"]
		for inner_polygon in polygon_group["inners"]:
			polygon = resolve_hole(polygon, inner_polygon)
		results.append(polygon)
	return results

static func has_hole(polygons: Array) -> bool:
	for polygon in polygons:
		if Geometry2D.is_polygon_clockwise(polygon):
			return true
	return false

static func _find_closest_points(polygon1: PackedVector2Array, polygon2: PackedVector2Array) -> Array:
	var minimal_distance = INF
	var minimal_distance_indexes
	for i in range(polygon1.size()):
		for j in range(polygon2.size()):
			var distance = polygon1[i].distance_squared_to(polygon2[j])
			if distance < minimal_distance:
				minimal_distance = distance
				minimal_distance_indexes = [i, j]
	return minimal_distance_indexes

static func _group_for_holes(polygons: Array) -> Array:
	var outer = []
	var inners = []
	for polygon in polygons:
		if Geometry2D.is_polygon_clockwise(polygon):
			inners.append(polygon)
		else:
			outer.append(polygon)
	
	var results = []
	for outer_polygon in outer:
		var inners_of_outer_with_distance = []

		for inner_index in range(inners.size()-1, -1, -1):
			var inner_polygon = inners[inner_index]

			if Geometry2D.is_point_in_polygon(inner_polygon[0], outer_polygon):
				var connecting_edge_indexes = _find_closest_points(outer_polygon, inner_polygon)
				var connecting_edge = [outer_polygon[connecting_edge_indexes[0]], inner_polygon[connecting_edge_indexes[1]]]
				inners_of_outer_with_distance.append({
					"inner_polygon": inner_polygon,
					"distance": connecting_edge[0].distance_squared_to(connecting_edge[1]),
				})

				inners.remove_at(inner_index)
		inners_of_outer_with_distance.sort_custom(Callable(DistanceKeySorter, "sort_ascending"))
		var inners_of_outer = []
		for inner_with_distance in inners_of_outer_with_distance:
			inners_of_outer.append(inner_with_distance.inner_polygon)
		results.append({
			"outer": outer_polygon,
			"inners": inners_of_outer,
		})
	return results

static func resolve_hole(outer: Array, inner: Array) -> PackedVector2Array:
	assert(Geometry2D.is_polygon_clockwise(inner))
	assert(not Geometry2D.is_polygon_clockwise(outer))
	
	var edge_indexes = _find_closest_points(outer, inner)

	var result = _shift_array(outer, edge_indexes[0])

	if result.back() != result.front():
		result.append(result.front())

	var shifted_inner = _shift_array(inner, edge_indexes[1])

	result.append_array(shifted_inner)

	if shifted_inner.back() != shifted_inner.front():
		result.append(shifted_inner.front())

	return PackedVector2Array(result)

static func _shift_array(arr: Array, begin_index: int) -> Array:
	if (begin_index % arr.size()) == 0:
		return arr
	var result = arr.slice(begin_index, arr.size() - 1)
	result.append_array(arr.slice(0, begin_index - 1))
	return result

static func clip(polygon: PackedVector2Array, clipping_polygon: PackedVector2Array) -> Array:
	var clipped = Geometry2D.clip_polygons(polygon, clipping_polygon)
	return resolve_holes(clipped)


static func merge(polygons_to_merge: Array) -> Array:
	if len(polygons_to_merge) < 2:
		return polygons_to_merge

	var polygons = polygons_to_merge.duplicate()

	var unmerged_polygons = polygons.duplicate()
	while not unmerged_polygons.is_empty():

		for i in range(unmerged_polygons.size()-1, -1, -1):
			var unmerged_polygon = unmerged_polygons[i]
			unmerged_polygons.remove_at(i)
			for j in range(polygons.size()-1, -1, -1):
				var polygon = polygons[j]
				if unmerged_polygon == polygon:
					continue
				
				var merged1 = Geometry2D.merge_polygons(unmerged_polygon, polygon)
				var merged = resolve_holes(merged1)
				assert(not has_hole(merged))
				
				match merged.size():
					0:
						break
					1:
						polygons.remove_at(j)
						polygons.erase(unmerged_polygon)
						polygons.append(merged[0])

						unmerged_polygons.append(merged[0])

						break
					_:

						pass
	return polygons

class DistanceKeySorter:
	static func sort_ascending(a, b) -> bool:
		if a["distance"] < b["distance"]:
			return true
		return false
