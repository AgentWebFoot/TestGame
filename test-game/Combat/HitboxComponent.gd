extends Area2D
class_name HitboxComponent

@export var health_component : HealthComponent
@export var knockback_body: CharacterBody2D
@export var damage_visual: CanvasItem
@export var hit_cooldown: float = 0.4
@export var flash_duration: float = 0.1

var can_be_hit: bool = true

func damage(attack: Attack):
	if not can_be_hit:
		return
	
	can_be_hit = false
	
	if health_component:
		health_component.damage(attack)
	if knockback_body and knockback_body.has_method("apply_knockback"):
		var direction := (
			knockback_body.global_position - attack.attack_position
		).normalized()

		knockback_body.apply_knockback(
			direction,
			attack.knockback_force
		)
	flash_red()
	await get_tree().create_timer(hit_cooldown).timeout
	can_be_hit = true

func flash_red() -> void:
	if not damage_visual:
		return

	damage_visual.modulate = Color.RED

	await get_tree().create_timer(flash_duration).timeout

	if is_instance_valid(damage_visual):
		damage_visual.modulate = Color.WHITE
