extends CharacterBody2D

# Le signal pour avertir le monde que la partie est finie
signal mort_signalee

const GRAVITE = 1200.0    
const PUISSANCE_SAUT = -400.0
const SAUT_DE_MORT = -600.0

# Paramètres de rotation ajustés
const ROTATION_HAUT = -0.6  # Angle quand l'oiseau monte
const ROTATION_BAS = 0.3    # Angle quand l'oiseau descend (doux)
const VITESSE_ROTATION = 8.0 # Fluidité du basculement

var est_mort = false

func _physics_process(delta):
	# Naborim subit toujours la gravité (même mort, pour tomber à l'eau)
	velocity.y += GRAVITE * delta

	# --- SI NABORIM EST VIVANT ---
	if not est_mort:
		# Saut via le clavier, la manette ou l'écran tactile
		if Input.is_action_just_pressed("ui_accept"):
			sauter()
			
		# Rotation dynamique selon la direction verticale
		var cible_rotation = ROTATION_HAUT if velocity.y < 0 else ROTATION_BAS
		rotation = lerp(rotation, cible_rotation, VITESSE_ROTATION * delta)
		
		# Gestion des animations de vol et de chute
		if has_node("AnimatedSprite2D"):
			if velocity.y < 0:
				$AnimatedSprite2D.play("vol")
			else:
				$AnimatedSprite2D.play("chute")

	# Naborim bouge en fonction de la gravité et des sauts
	move_and_slide()
	
	# LES LIMITES DE L'ÉCRAN (Plafond ou sol)
	var taille_ecran = get_viewport_rect().size
	if not est_mort:
		if position.y <= 0 or position.y >= taille_ecran.y:
			mourir()

# GESTION DES CONTRÔLES TACTILES (MOBILE)
func _input(event):
	if not est_mort and event is InputEventScreenTouch:
		if event.pressed: 
			sauter()

# Fonction centralisée pour le saut
func sauter():
	velocity.y = PUISSANCE_SAUT

func mourir():
	if est_mort:
		return
		
	est_mort = true
	print("GAME OVER ! Appuyez pour recommencer.")
	
	# On avertit le script du monde pour afficher l'écran Game Over
	emit_signal("mort_signalee")
	
	# LE BOND DE LA MORT
	velocity.y = SAUT_DE_MORT
	
	# --- MODIFIÉ ICI : On force l'oiseau à être parfaitement droit (0.0 = plat) ---
	rotation = 0.0
	
	# On joue l'animation de mort
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("mort")
		
	# LA MAGIE DE LA PAUSE
	# 1. On permet à Naborim de continuer à bouger (pour sa chute) malgré la pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 2. On fige le reste du monde (les tentacules et le défilement s'arrêtent)
	get_tree().paused = true
