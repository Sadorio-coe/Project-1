extends CharacterBody2D

# --- NOUVEAU : Le signal pour avertir le monde que la partie est finie ---
signal mort_signalee

const GRAVITE = 1200.0     
const PUISSANCE_SAUT = -400.0 
const SAUT_DE_MORT = -600.0 

var est_mort = false
var region_de_mort = Rect2(187, 147, 55, 50) 

func _physics_process(delta):
	# Naborim subit toujours la gravité, même mort
	velocity.y += GRAVITE * delta

	# --- SI NABORIM EST VIVANT ---
	if not est_mort and Input.is_action_just_pressed("ui_accept"):
		velocity.y = PUISSANCE_SAUT

	# Naborim bouge en fonction de la gravité et des sauts
	move_and_slide()
	
	# --- LES LIMITES DE L'ÉCRAN (Désormais mortelles !) ---
	var taille_ecran = get_viewport_rect().size
	
	if not est_mort:
		# Si Naborim touche le plafond (<= 0) ou le sol (>= taille_ecran.y)
		if position.y <= 0 or position.y >= taille_ecran.y:
			mourir()


func mourir():
	if est_mort:
		return 
		
	est_mort = true
	print("GAME OVER ! Appuyez pour recommencer.")
	
	# --- NOUVEAU : Naborim déclenche le signal ---
	emit_signal("mort_signalee")
	
	# --- LE BOND DE LA MORT PLUS HAUT ---
	velocity.y = SAUT_DE_MORT
	
	if has_node("Sprite2D"):
		$Sprite2D.region_rect = region_de_mort
		
	# --- LA MAGIE DE LA PAUSE EST ICI ---
	# 1. On dit à Naborim de continuer à "vivre" même si le jeu est en pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 2. On fige tout le reste du jeu (Tentacules, Timer, etc.)
	get_tree().paused = true
