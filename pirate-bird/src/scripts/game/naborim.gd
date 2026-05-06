extends CharacterBody2D

# Le signal pour avertir le monde que la partie est finie
signal mort_signalee

const GRAVITE = 1200.0     
const PUISSANCE_SAUT = -400.0 
const SAUT_DE_MORT = -600.0 

# --- NOUVEAU : Paramètres de rotation ---
const ROTATION_HAUT = -0.6  # Angle quand l'oiseau monte (en radians)
const ROTATION_BAS = 1.0    # Angle quand l'oiseau tombe
const VITESSE_ROTATION = 10.0 # Fluidité de la rotation

var est_mort = false
var region_de_mort = Rect2(187, 147, 55, 50) 

func _physics_process(delta):
	# Naborim subit toujours la gravité
	velocity.y += GRAVITE * delta

	# --- SI NABORIM EST VIVANT ---
	if not est_mort:
		# Saut via le clavier ou la manette
		if Input.is_action_just_pressed("ui_accept"):
			sauter()
			
		# --- NOUVEAU : ROTATION DYNAMIQUE ---
		# Calcul de la rotation cible basée sur la direction (velocity.y)
		var cible_rotation = ROTATION_HAUT if velocity.y < 0 else ROTATION_BAS
		
		# Application fluide de la rotation
		rotation = lerp(rotation, cible_rotation, VITESSE_ROTATION * delta)

	# Naborim bouge en fonction de la gravité et des sauts
	move_and_slide()
	
	# LES LIMITES DE L'ÉCRAN
	var taille_ecran = get_viewport_rect().size
	if not est_mort:
		if position.y <= 0 or position.y >= taille_ecran.y:
			mourir()

# --- NOUVEAU : GESTION DES CONTRÔLES TACTILES ---
func _input(event):
	if not est_mort and event is InputEventScreenTouch:
		if event.pressed: # On vérifie qu'il s'agit d'un "tap" et non d'un relâchement
			sauter()

# Fonction centralisée pour le saut
func sauter():
	velocity.y = PUISSANCE_SAUT

func mourir():
	if est_mort:
		return 
		
	est_mort = true
	print("GAME OVER ! Appuyez pour recommencer.")
	
	emit_signal("mort_signalee")
	
	# LE BOND DE LA MORT PLUS HAUT
	velocity.y = SAUT_DE_MORT
	
	# On bascule la tête vers le bas quand il meurt
	rotation = ROTATION_BAS
	
	if has_node("Sprite2D"):
		$Sprite2D.region_rect = region_de_mort
		
	# LA MAGIE DE LA PAUSE EST ICI
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
