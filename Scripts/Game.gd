class_name Game;
extends Node;

@export_category("Scenes")
@export var lobby_scene: PackedScene;
@export var level_scene: PackedScene;

const PORT: int = 9999;
var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new();
var lobby: Lobby;

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
	
	lobby._show_lobby();
	
	upnp_setup();
	
func _on_join() -> void:
	enet_peer.create_client(lobby.address_entry.text, PORT);
	multiplayer.multiplayer_peer = enet_peer;
	
	lobby._show_lobby();

func _start_game() -> void:
	if multiplayer.is_server():
		lobby.queue_free();

	var level: Node2D = level_scene.instantiate();
	add_child(level, true);

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
