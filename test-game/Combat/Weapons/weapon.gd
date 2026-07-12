extends Node2D

@export var attack_damage := 10.0
@export var knockback_force := 100.0
@export var attack_duration: float = 0.15
@export var attack_cooldown: float = 0.35

@onready var weapon_sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var can_attack := true
var hit_targets: Array[Area2D] = []

func _ready() -> void:
	attack_shape.disabled = true
	weapon_sprite.visible = false

	attack_timer.one_shot = true
	cooldown_timer.one_shot = true

	attack_timer.timeout.connect(_on_attack_timer_timeout)
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	
	attack_area.area_entered.connect(_on_hitbox_area_entered)

func attack() -> void:
	if not can_attack:
		return

	can_attack = false
	hit_targets.clear()

	attack_shape.set_deferred("disabled", false)
	attack_timer.start(attack_duration)

	play_attack_animation()

func play_attack_animation():
	weapon_sprite.visible = true
	animation_player.play("Attack")


func _on_attack_timer_timeout() -> void:
	attack_shape.set_deferred("disabled", true)
	weapon_sprite.visible = false
	animation_player.stop()
	cooldown_timer.start(attack_cooldown)


func _on_cooldown_timer_timeout() -> void:
	can_attack = true

func _on_hitbox_area_entered(area):
	if area is HitboxComponent:
		var hitbox : HitboxComponent = area
		
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.knockback_force = knockback_force
		attack.attack_position = global_position
		
		hitbox.damage(attack)
