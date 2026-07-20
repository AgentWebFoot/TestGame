extends WeaponEnemy
class_name RangedWeaponEnemy

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 200.0
@export var projectile_range: float = 180.0
@export var projectile_spawn_distance: float = 12.0

func _perform_attack(target_position: Vector2) -> void:
	_spawn_projectile(target_position)

func _spawn_projectile(target_position: Vector2) -> Node2D:
	if projectile_scene == null:
		return null

	var projectile := projectile_scene.instantiate()
	if not (projectile is Node2D):
		return null

	var direction := global_position.direction_to(target_position)
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT

	var projectile_lifetime := 0.0
	if projectile_speed > 0.0:
		projectile_lifetime = projectile_range / projectile_speed

	if projectile.has_method("configure"):
		projectile.configure(
			direction,
			projectile_speed,
			projectile_lifetime,
			attack_damage,
			knockback_force,
			stun_duration,
			get_parent() as Node2D
		)

	var projectile_node := projectile as Node2D
	projectile_node.global_position = global_position + (direction * projectile_spawn_distance)
	projectile_node.rotation = direction.angle()

	var scene_root := get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root

	scene_root.add_child(projectile_node)
	return projectile_node
