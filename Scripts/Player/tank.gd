class_name Player;
extends CharacterBody2D

@export_category("settings")
@export var spawn_position: Vector2;

@export_category("tank_parts")
@export var body: Sprite2D;
@export var turret: Sprite2D;

@export_category("tank_ui")
@export var shoot_progress: TextureProgressBar;

@export_category("nodes")
@export var projectile_container_name: String;

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	position = spawn_position;

func _physics_process(delta):
	move_and_slide();
