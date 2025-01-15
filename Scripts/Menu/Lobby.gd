class_name Lobby;
extends Node;

@export_category("Nodes")
@export var main_menu: Panel;
@export var lobby_panel: Panel;
@export var address_entry: TextEdit;
@export var player_list: VBoxContainer;

@export_category("Scenes")
@export var player_scene: PackedScene;

signal host_game;
signal join_game;
signal start_game;

const PORT: int = 9999;
var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new();

func show_lobby() -> void:
	main_menu.hide();
	lobby_panel.show();

func _on_host_button_pressed() -> void:
	host_game.emit();
	
func _on_join_button_pressed() -> void:	
	join_game.emit();
	
func _on_start_button_pressed() -> void:	
	start_game.emit();

func add_player(peer_id) -> void:
	if not multiplayer.is_server():
		return
	var player = player_scene.instantiate();
	player.text = str(peer_id);
	player_list.add_child(player, true);
	#if player.is_multiplayer_authority():
		#player.health_changed.connect(update_health_bar)
		#pass;
	#var name_panel: Label = Label.new();
	#name_panel.text = str(peer_id);
	#player_list.add_child(name_panel)

func remove_player(peer_id) -> void:
	if not multiplayer.is_server():
		return
	var name_panel = get_node_or_null(str(peer_id));
	if name_panel:
		name_panel.queue_free();
