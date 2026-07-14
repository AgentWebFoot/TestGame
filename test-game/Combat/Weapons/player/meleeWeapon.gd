extends Weapon
class_name MeleeWeapon

enum AttackMode {
	NORMAL,
	ALT
}

@export_group("Main Attack")
@export var attack_damage := 10.0
@export var knockback_force := 100.0
@export var attack_duration: float = 0.15
@export var stun_duration: float = 0.0

@export_group("Alt Attack")
@export var alt_attack_damage: float = 20.0
@export var alt_attack_knockback_force: float = 260.0
@export var alt_attack_duration: float = 0.50
@export var alt_attack_cooldown: float = 1
@export var alt_attack_stun_duration: float = 0.35
@export var alt_attack_animation_speed_scale: float = 0.65

@onready var weapon_sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var alt_attack_sprite: Sprite2D = get_node_or_null("AltAttack") as Sprite2D
@onready var alt_attack_area: Area2D = get_node_or_null("AltAttackArea") as Area2D
@onready var alt_attack_shape: CollisionShape2D = get_node_or_null("AltAttackArea/CollisionShape2D") as CollisionShape2D

var current_attack_mode: AttackMode = AttackMode.NORMAL
var active_attack_damage: float = 0.0
var active_knockback_force: float = 0.0
var active_stun_duration: float = 0.0
var default_sprite_scale: Vector2 = Vector2.ONE
var default_hitbox_scale: Vector2 = Vector2.ONE
var default_alt_sprite_scale: Vector2 = Vector2.ONE
var default_alt_hitbox_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	super._ready()
	attack_shape.disabled = true
	weapon_sprite.visible = false
	default_sprite_scale = weapon_sprite.scale
	default_hitbox_scale = attack_shape.scale
	if alt_attack_sprite != null:
		alt_attack_sprite.visible = false
		default_alt_sprite_scale = alt_attack_sprite.scale
	if alt_attack_shape != null:
		alt_attack_shape.disabled = true
		default_alt_hitbox_scale = alt_attack_shape.scale
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_area.area_entered.connect(_on_hitbox_area_entered)
	if alt_attack_area != null:
		alt_attack_area.area_entered.connect(_on_hitbox_area_entered)

func attack() -> void:
	if not can_attack:
		return

	can_attack = false
	is_attacking = true
	current_attack_mode = AttackMode.NORMAL
	set_cooldown_override(attack_cooldown)
	_begin_attack()

func alt_attack() -> void:
	if not can_attack:
		return

	can_attack = false
	is_attacking = true
	current_attack_mode = AttackMode.ALT
	set_cooldown_override(alt_attack_cooldown)
	_begin_attack()

func _begin_attack() -> void:
	match current_attack_mode:
		AttackMode.ALT:
			active_attack_damage = alt_attack_damage
			active_knockback_force = alt_attack_knockback_force
			active_stun_duration = alt_attack_stun_duration
			animation_player.speed_scale = alt_attack_animation_speed_scale
			attack_timer.start(alt_attack_duration)
		_:
			active_attack_damage = attack_damage
			active_knockback_force = knockback_force
			active_stun_duration = stun_duration
			weapon_sprite.scale = default_sprite_scale
			attack_shape.scale = default_hitbox_scale
			if alt_attack_sprite != null:
				alt_attack_sprite.scale = default_alt_sprite_scale
			if alt_attack_shape != null:
				alt_attack_shape.scale = default_alt_hitbox_scale
			animation_player.speed_scale = 1.0
			attack_timer.start(attack_duration)

	_set_active_attack_collision_enabled(true)
	play_attack_animation()

func play_attack_animation() -> void:
	weapon_sprite.visible = false
	if alt_attack_sprite != null:
		alt_attack_sprite.visible = false

	if current_attack_mode == AttackMode.ALT and _has_alt_attack_nodes():
		alt_attack_sprite.visible = true
		animation_player.play("AltAttack")
		return

	weapon_sprite.visible = true
	animation_player.play("Attack")

func _on_attack_timer_timeout() -> void:
	_set_active_attack_collision_enabled(false)
	weapon_sprite.visible = false
	if alt_attack_sprite != null:
		alt_attack_sprite.visible = false
	weapon_sprite.scale = default_sprite_scale
	attack_shape.scale = default_hitbox_scale
	if alt_attack_sprite != null:
		alt_attack_sprite.scale = default_alt_sprite_scale
	if alt_attack_shape != null:
		alt_attack_shape.scale = default_alt_hitbox_scale
	animation_player.stop()
	animation_player.speed_scale = 1.0
	finish_attack()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var hitbox := area as HitboxComponent
		var attack := Attack.new()
		attack.attack_damage = active_attack_damage
		attack.knockback_force = active_knockback_force
		attack.attack_position = global_position
		attack.stun_duration = active_stun_duration
		attack.source_node = get_parent() as Node2D
		hitbox.damage(attack)

func _has_alt_attack_nodes() -> bool:
	return alt_attack_sprite != null and alt_attack_area != null and alt_attack_shape != null

func _set_active_attack_collision_enabled(enabled: bool) -> void:
	attack_shape.set_deferred("disabled", not enabled)

	if alt_attack_shape != null:
		alt_attack_shape.set_deferred("disabled", true)

	if current_attack_mode == AttackMode.ALT and _has_alt_attack_nodes():
		attack_shape.set_deferred("disabled", true)
		alt_attack_shape.set_deferred("disabled", not enabled)
