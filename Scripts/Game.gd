class_name Game;
extends Node;

@export_category("Scenes")
@export var lobby_scene: PackedScene;
@export var level_scene: PackedScene;

const PORT: int = 9998;
var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new();
var lobby: Lobby;
var player_list: Array;

func _ready():
	lobby = lobby_scene.instantiate();
	add_child(lobby, true);
	lobby.host_game.connect(_on_host);
	lobby.join_game.connect(_on_join);
	lobby.start_game.connect(_start_game);

func _on_host() -> void:
	enet_peer.create_server(PORT);
	multiplayer.multiplayer_peer = enet_peer;
	multiplayer.peer_connected.connect(lobby.add_player);
	multiplayer.peer_disconnected.connect(lobby.remove_player);
	
	lobby.add_player(multiplayer.get_unique_id());
	
	player_list.append(multiplayer.get_unique_id());
	
	lobby.show_lobby();
	
	upnp_setup();
	
func _on_join() -> void:
	enet_peer.create_client(lobby.address_entry.text, PORT);
	multiplayer.multiplayer_peer = enet_peer;
	
	lobby.show_lobby();
	
	await get_tree().create_timer(1).timeout

	_client_join.rpc(multiplayer.get_unique_id());

func _start_game() -> void:
	if multiplayer.is_server():
		lobby.queue_free();
		
		_client_start.rpc();

	var level: Level = level_scene.instantiate();
	add_child(level, true);
	level.add_players(player_list);

@rpc("any_peer", "call_remote")
func _client_join(id) -> void:
	player_list.append(id);

@rpc("any_peer", "call_remote")
func _client_start() -> void:
	if not multiplayer.is_server():
		lobby.hide();
		pass;

func upnp_setup() -> void:
	var upnp = UPNP.new();
	
	var discover_result = upnp.discover();
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result);

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!");

	var map_result = upnp.add_port_mapping(PORT);
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result);
	
	print("Success! Join Address: %s" % upnp.query_external_address());
