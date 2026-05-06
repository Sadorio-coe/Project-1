extends "res://src/scripts/game/obstacle_base.gd"

# --- CONFIGURATION DE LA MOUETTE ---
func _ready():
	# Force le lancement de l'animation de vol
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("vol")
	
	# Connecte automatiquement le signal de collision au démarrage
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta):
	# 1. Mouvement horizontal automatique (géré par le parent ObstacleBase)
	super._process(delta)
	
	# 2. Ondulation verticale (Mouvement sinusoïdal)
	position.y += sin(Time.get_ticks_msec() * 0.005) * 2

# Déclenché dès que Naborim touche ton magnifique polygone
func _on_body_entered(body):
	# On s'assure que c'est bien l'oiseau du joueur qui a touché l'obstacle
	if body.name == "Naborim" and body.has_method("mourir"):
		body.mourir()
