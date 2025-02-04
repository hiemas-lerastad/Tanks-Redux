extends Control

@export_category("stats")
@export var health_container: TextureProgressBar

var linked_player: Player
var game_over: bool = false;

func check_visible_status() -> void:
	if linked_player:
		if Globals.player_turn == linked_player.id or game_over:
			visible = true;
		else:
			visible = false;

func check_game_over_status():
	#if(linked_player.is_game_over):
		#if(linked_player.still_playing == false):
			#$end_panel.visible = true
			#$end_panel/end_condition.text = "You Lost!"
		#else:
			#$end_panel.visible = true
			#$end_panel/end_condition.text = "You Won!"
			
	var active_local_players: Array;
	var active_players: Array;
	
	for player in Globals.player_list:
		if player.active:
			active_players.append(player);
			if player.multiplayer_id == multiplayer.get_unique_id():
				active_local_players.append(player);
	
	if active_players.size() == 1:
		game_over = true;
		if active_local_players.size() > 0:
			$end_panel.visible = true
			$end_panel/end_condition.text = "Player " + str(active_players[0].id) + " Won!"
		else:
			$end_panel.visible = true
			$end_panel/end_condition.text = "You Lost!"

func _process(delta):
	check_visible_status()
	check_game_over_status()
	health_container.value = linked_player.health_component.current_health
