class_name Weapons extends Resource

@export var name : String

@export_category("Weapon Orientation")
@export var positionOffset : Vector2
@export var rotationOffset : float

@export_category("Sway Orientation")
@export var sway_sensitivity_multiplier : float = 1
@export var sway_speed_multiplier : float = 1

@export_category("Idle Animation")
@export var idle_anim_adjust : float = 10
@export var idle_anim_speed : float = 5
@export var idle_anim_amplitude : float = 300
@export var idle_anim_random_amount : float = 6

@export_category("Visual Settings")
@export var weaponSprite : CompressedTexture2D
