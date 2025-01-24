extends Node

var level: Level;
var player_container: Node2D;
var projectile_container: Node2D;

enum Game_States {LOBBY, MATCH, MATCH_OVER}

@export var game_state: Game_States = Game_States.LOBBY;
@export var player_turn: int = 0;
@export var player_list: Array;

@rpc("any_peer", "call_remote")
func set_player_list(player_list: Array) -> void:
	Globals.player_list = player_list;

@rpc("any_peer", "call_remote")
func set_player_turn(id: int) -> void:
	Globals.player_turn = id;
