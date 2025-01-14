class_name Player;
extends CharacterBody2D

@export var spawn_position: Vector2;

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	position = spawn_position;

func _physics_process(delta):
	move_and_slide();
