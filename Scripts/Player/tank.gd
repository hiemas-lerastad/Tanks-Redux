extends CharacterBody2D

@export_category("tank_parts")
@export var body: Sprite2D
@export var turret: Sprite2D

@export_category("tank_ui")
@export var shoot_progress: TextureProgressBar

func _physics_process(delta):
	move_and_slide()
