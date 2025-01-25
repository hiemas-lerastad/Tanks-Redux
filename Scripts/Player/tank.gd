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
@export var health_component: Node;
@export var projectile_container_name: String;

var still_playing: bool = true
var is_game_over: bool
func _knocked_out():
	still_playing = false
	visible = false
	$CollisionShape2D.disabled = true

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	position = spawn_position;

func _physics_process(delta):
	move_and_slide();
