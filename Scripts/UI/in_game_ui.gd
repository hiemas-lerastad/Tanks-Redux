extends Control

@export_category("stats")
@export var health_container: TextureProgressBar

var linked_player: Player

func check_game_over_status():
	if(linked_player.is_game_over):
		if(linked_player.still_playing == false):
			$end_panel.visible = true
			$end_panel/end_condition.text = "You Lost!"
		else:
			$end_panel.visible = true
			$end_panel/end_condition.text = "You Won!"

func _process(delta):
	
	check_game_over_status()
	health_container.value = linked_player.health_component.current_health
