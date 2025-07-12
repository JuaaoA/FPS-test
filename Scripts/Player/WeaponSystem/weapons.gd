class_name Weapons extends Resource

@export var name : String

@export_category("Weapon Orientation")
@export var positionOffset : Vector2
@export var rotationOffset : float

@export_category("Sway Orientation")
@export var sway_sensitivity_multiplier : float = 1
@export var sway_speed_multiplier : float = 1

@export_category("Idle Animation")
@export var idle_anim_speed : float = 1
@export var idle_anim_random_amount : float = 6

@export_category("Weapon Settings")
@export var reload_time : float = 1.0
@export var fire_rate : float = 0.1
@export var ammo_capacity : int = 30
@export var damage : float = 10.0
@export var pulling_time : float = 0.5

@export_category("Visual Settings")
@export var weaponSprite : CompressedTexture2D
@export var skin : Resource
