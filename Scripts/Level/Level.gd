class_name Level;
extends Node2D;

@export_category("Nodes")
@export var terrain: Terrain;
@export var player_container: Node2D;

@export_category("Scenes")
@export var player_scene: PackedScene;

func add_players(player_list: Array) -> void:
	if multiplayer.is_server():
		for index in player_list.size():
			var player: int = player_list[index];
			var player_instance: Player = player_scene.instantiate();
#
			#player_instance.name = str(player);
			#player_instance.spawn_position = Vector2(player_instance.position.x + (index * 200), player_instance.position.y);
			#
			player_instance.name = str(player);
			player_container.add_child(player_instance)
			
			setup_player.rpc_id(player, player, index)
		
@rpc("call_local", "reliable")
func setup_player(player: int, index: int) -> void:
	print(player_container.get_node_or_null(str(player)))
	if player_container.get_node_or_null(str(player)):
		var player_instance: Player = player_container.get_node_or_null(str(player));

		player_instance.position = Vector2(player_instance.position.x + (index * 200), player_instance.position.y);
	
