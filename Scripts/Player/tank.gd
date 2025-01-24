class_name Player;
extends CharacterBody2D

@export_category("settings")
@export var spawn_position: Vector2;
@export var id: int;
@export var multiplayer_id: int;

@export_category("tank_parts")
@export var body: Sprite2D;
@export var turret: Sprite2D;

@export_category("tank_ui")
@export var shoot_progress: TextureProgressBar;

@export_category("nodes")
@export var projectile_container_name: String;

func _enter_tree():
	if (multiplayer_id) == 0:
		for index in Globals.player_list.size():
			if name.to_int() == Globals.player_list[index].id:
				multiplayer_id = Globals.player_list[index].multiplayer_id;
				id = Globals.player_list[index].id;

	set_multiplayer_authority(str(multiplayer_id).to_int())
	position = spawn_position;

func _physics_process(delta):
	move_and_slide();
