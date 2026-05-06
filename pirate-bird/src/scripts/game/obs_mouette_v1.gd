extends "res://src/scripts/game/obstacle_base.gd"

# --- CONFIGURATION DE LA MOUETTE ---
func _ready():
	# Si tu as une animation de battement d'ailes, lance-la ici
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("vol")

func _process(delta):
	# 1. Mouvement horizontal (géré par le parent ObstacleBase)
	super._process(delta)
	
	# 2. Ondulation verticale (Mouvement sinusoïdal)
	# On utilise le temps pour faire varier la position Y de façon fluide
	position.y += sin(Time.get_ticks_msec() * 0.005) * 2
