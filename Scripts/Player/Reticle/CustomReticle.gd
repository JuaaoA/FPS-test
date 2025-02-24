extends Node2D

# PROPRIEDADES DA RETICULA CUSTOMIZADA
@onready var sprite_object = $ReticleSprite

@export var sprites_list : Array[CompressedTexture2D]

func change_sprite(sprite_name : String):
	
	# Definir um index
	var s_index = 0

	# Verificar que sprite alterar de acordo com o nome
	match (sprite_name):

		"climb_indicator":
			s_index = 0

		"walljump_indicator":
			s_index = 1

	# Definir a textura
	sprite_object.texture = sprites_list[s_index]
