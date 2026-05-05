extends Area2D

# C'est la scène "le_monde" qui va lui donner sa vraie vitesse à chaque apparition !
var vitesse = 0 

# --- NOUVEAU : GESTION DES ANIMATIONS D'APPARITION ---
func _ready():
	# Dès que la tentacule apparaît, on joue l'animation d'entrée
	$AnimationPlayer.play("Entree")
	
	# On attend que l'animation d'entrée soit totalement finie
	await $AnimationPlayer.animation_finished
	
	# Puis on lance l'ondulation infinie
	$AnimationPlayer.play("Idle")


func _process(delta):
	# 1. On fait avancer la tentacule vers la gauche à chaque image
	position.x -= vitesse * delta
	
	# 2. Si elle dépasse le côté gauche de l'écran...
	# On vérifie aussi qu'on ne joue pas DÉJÀ la sortie, pour ne pas la déclencher 60 fois par seconde !
	if position.x < 70 and $AnimationPlayer.current_animation != "Sortie":
		disparaitre_et_supprimer()


# --- NOUVEAU : FONCTION DE PLONGEON ET SUPPRESSION ---
func disparaitre_et_supprimer():
	# On joue l'animation de plongeon
	$AnimationPlayer.play("Sortie")
	
	# On désactive ton nouveau polygone de collision (le joueur est safe !)
	$CollisionPolygon2D.set_deferred("disabled", true)
	
	# On attend que le splash soit terminé
	await $AnimationPlayer.animation_finished
	
	# On supprime proprement l'objet
	queue_free()


# --- DÉTECTION DE COLLISION AVEC LA TENTACULE (MORT) ---
func _on_body_entered(body):
	# 'body' représente ce qui vient de rentrer dans la tentacule (ici, Naborim)
	if body.has_method("mourir"):
		body.mourir()


# --- DÉTECTION AVEC LA LIGNE INVISIBLE (SCORE) ---
func _on_zone_score_body_entered(body):
	# On vérifie bien le nom avec le "m" !
	if body.name == "Naborim":
		# On appelle la fonction du monde pour ajouter le point au compteur
		get_tree().current_scene.ajouter_point()
		
		# On désactive la surveillance de la zone de score pour ne pas faire +1 en boucle
		$ZoneScore.set_deferred("monitoring", false)
