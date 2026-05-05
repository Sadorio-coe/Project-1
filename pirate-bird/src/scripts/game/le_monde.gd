extends Node2D

var tentacule_scene = preload("res://src/Scenes/game/tentacule.tscn")

# --- PARAMÈTRES DE DIFFICULTÉ ---
var vitesse_fond = 200 # Remis à une valeur raisonnable pour tester
var vitesse_tentacules = 250
var vitesse_max_tentacules = 850
var temps_apparition_min = 0.7

# --- VARIABLES DU JEU ---
var score = 0
var temps_ecoule = 0.0
var jeu_en_cours = true

# --- SYSTÈME DE SAUVEGARDE (TOP 50) ---
var liste_scores = [] 
var chemin_sauvegarde = "user://historique_pirate.save"

func _ready():
	charger_scores() 
	get_tree().paused = false
	print("Jeu prêt - Naborim est en position.")

func _process(delta):
	if jeu_en_cours:
		temps_ecoule += delta 
		
		# Mise à jour du HUD
		if has_node("HUD/TimeLabel"):
			$HUD/TimeLabel.text = "Temps : " + str(int(temps_ecoule)) + "s"
		
		# --- TESTS DE MOUVEMENT DU FOND ---
		# Test 1 : ParallaxBackground (Normal)
		if has_node("ParallaxBackground"):
			$ParallaxBackground.scroll_base_offset.x -= vitesse_fond * delta
		
		# Test 2 : ParallaxLayer (Direct)
		if has_node("ParallaxBackground/ParallaxLayer"):
			$ParallaxBackground/ParallaxLayer.motion_offset.x -= vitesse_fond * delta
			
		# Test 3 : Sprite (Forcé) - Si ça bouge, l'image va glisser vers la gauche
		if has_node("ParallaxBackground/ParallaxLayer/Sprite2D"):
			$ParallaxBackground/ParallaxLayer/Sprite2D.position.x -= vitesse_fond * delta

func _on_timer_timeout():
	if not jeu_en_cours: return
	
	var nouvelle_tentacule = tentacule_scene.instantiate()
	var taille_ecran = get_viewport_rect().size
	
	nouvelle_tentacule.position.x = taille_ecran.x - 50
	
	var zone_basse_min = taille_ecran.y - 300
	var zone_basse_max = taille_ecran.y - 100 
	nouvelle_tentacule.position.y = randf_range(zone_basse_min, zone_basse_max)
	
	nouvelle_tentacule.vitesse = vitesse_tentacules
	add_child(nouvelle_tentacule)

func ajouter_point():
	score += 1
	if has_node("HUD/ScoreLabel"):
		$HUD/ScoreLabel.text = "Score : " + str(score)
	
	if vitesse_tentacules < vitesse_max_tentacules:
		vitesse_tentacules += 4 
		vitesse_fond += 2 
	
	if has_node("Timer") and $Timer.wait_time > temps_apparition_min:
		$Timer.wait_time -= 0.02

# --- LES FONCTIONS QUI MANQUAIENT ---

func sauvegarder_nouveau_score(nouveau_score):
	liste_scores.append(nouveau_score)
	liste_scores.sort()
	liste_scores.reverse()
	if liste_scores.size() > 50:
		liste_scores = liste_scores.slice(0, 50)
	var fichier = FileAccess.open(chemin_sauvegarde, FileAccess.WRITE)
	if fichier:
		fichier.store_var(liste_scores)
		fichier.close()

func charger_scores():
	if FileAccess.file_exists(chemin_sauvegarde):
		var fichier = FileAccess.open(chemin_sauvegarde, FileAccess.READ)
		if fichier:
			liste_scores = fichier.get_var()
			fichier.close()
	else:
		liste_scores = []

func _on_naborim_mort_signalee():
	if not jeu_en_cours: return 
	jeu_en_cours = false 
	if has_node("HUD"): $HUD.visible = false
	if has_node("EcranGameOver"):
		$EcranGameOver.visible = true
		var ancien_meilleur = 0
		if liste_scores.size() > 0: ancien_meilleur = liste_scores[0]
		sauvegarder_nouveau_score(score)
		var texte_record = "Meilleur record : " + str(liste_scores[0])
		if score > ancien_meilleur: texte_record = "👑 NOUVEAU RECORD : " + str(score) + " 👑"
		$EcranGameOver/Panel/VBoxContainer/LabelScore.text = "Score : " + str(score)
		$EcranGameOver/Panel/VBoxContainer/LabelTemps.text = "Temps : " + str(int(temps_ecoule)) + "s"
		if has_node("EcranGameOver/Panel/VBoxContainer/LabelRecord"):
			$EcranGameOver/Panel/VBoxContainer/LabelRecord.text = texte_record

func _on_bouton_rejouer_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_bouton_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu_principal.tscn")
