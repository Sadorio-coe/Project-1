extends Node2D

# --- SYSTÈME DE BIOMES & OBSTACLES ---
enum Biome { OCEAN, PLAGE, GROTTE }
var biome_actuel = Biome.OCEAN

# Listes (Pools) des obstacles disponibles par biome
var obstacles_ocean = [ preload("res://src/Scenes/game/tentacule.tscn") ]
var obstacles_plage = [ preload("res://src/Scenes/game/tentacule.tscn") ]

# Dictionnaire des textures de fond par biome
var fonds_biomes = {
	Biome.OCEAN: preload("res://assets/Sprites/fond_jeu.png"),
	Biome.PLAGE: preload("res://assets/Sprites/fond_jeu.png") # À remplacer par ton image de plage plus tard
}

# --- PARAMÈTRES DE DIFFICULTÉ ---
var vitesse_fond = 200 
var vitesse_obstacles = 250
var vitesse_max_obstacles = 850
var temps_apparition_min = 0.7

# --- VARIABLES DU JEU ---
var score = 0
var temps_ecoule = 0.0
var jeu_en_cours = true

# --- SYSTÈME DE SAUVEGARDE ---
var liste_scores = [] 
var chemin_sauvegarde = "user://historique_pirate.save"

func _ready():
	charger_scores() # Cette fonction est maintenant bien définie ci-dessous
	get_tree().paused = false
	changer_biome(Biome.OCEAN)
	print("Jeu prêt - Naborim est en position.")

func _process(delta):
	if jeu_en_cours:
		temps_ecoule += delta 
		if has_node("HUD/TimeLabel"):
			$HUD/TimeLabel.text = "Temps : " + str(int(temps_ecoule)) + "s"
		
		if has_node("ParallaxBackground"):
			$ParallaxBackground.scroll_base_offset.x -= vitesse_fond * delta
		if has_node("ParallaxBackground/ParallaxLayer"):
			$ParallaxBackground/ParallaxLayer.motion_offset.x -= vitesse_fond * delta

func _on_timer_timeout():
	if not jeu_en_cours: return
	
	# Sélection de l'obstacle selon le biome
	var pool_actuel = obstacles_ocean
	if biome_actuel == Biome.PLAGE:
		pool_actuel = obstacles_plage
		
	var scene_choisie = pool_actuel[randi() % pool_actuel.size()]
	var nouvel_obstacle = scene_choisie.instantiate()
	
	var taille_ecran = get_viewport_rect().size
	nouvel_obstacle.position.x = taille_ecran.x - 50
	
	var zone_basse_min = taille_ecran.y - 300
	var zone_basse_max = taille_ecran.y - 100 
	nouvel_obstacle.position.y = randf_range(zone_basse_min, zone_basse_max)
	
	nouvel_obstacle.vitesse = vitesse_obstacles
	add_child(nouvel_obstacle)

func ajouter_point():
	score += 1
	if has_node("HUD/ScoreLabel"):
		$HUD/ScoreLabel.text = "Score : " + str(score)
		
	# Changement de biome au palier 10
	if score == 10 and biome_actuel != Biome.PLAGE:
		changer_biome(Biome.PLAGE)
	
	if vitesse_obstacles < vitesse_max_obstacles:
		vitesse_obstacles += 4 
		vitesse_fond += 2 
	
	if has_node("Timer") and $Timer.wait_time > temps_apparition_min:
		$Timer.wait_time -= 0.02

func changer_biome(nouveau_biome):
	biome_actuel = nouveau_biome
	if has_node("ParallaxBackground/ParallaxLayer/Sprite2D"):
		$ParallaxBackground/ParallaxLayer/Sprite2D.texture = fonds_biomes[biome_actuel]

# --- FONCTIONS DE SAUVEGARDE ---
func charger_scores():
	if FileAccess.file_exists(chemin_sauvegarde):
		var fichier = FileAccess.open(chemin_sauvegarde, FileAccess.READ)
		if fichier:
			liste_scores = fichier.get_var()
			fichier.close()
	else:
		liste_scores = []

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

# --- SIGNAUX DE FIN DE PARTIE ---
func _on_naborim_mort_signalee():
	if not jeu_en_cours: return 
	jeu_en_cours = false 
	if has_node("HUD"): $HUD.visible = false
	if has_node("EcranGameOver"):
		$EcranGameOver.visible = true
		var ancien_meilleur = 0
		if liste_scores.size() > 0: 
			ancien_meilleur = liste_scores[0]
		
		sauvegarder_nouveau_score(score)
		
		var texte_record = "Meilleur record : " + str(liste_scores[0])
		if score > ancien_meilleur: 
			texte_record = "👑 NOUVEAU RECORD : " + str(score) + " 👑"
		
		$EcranGameOver/Panel/VBoxContainer/LabelScore.text = "Score : " + str(score)
		$EcranGameOver/Panel/VBoxContainer/LabelTemps.text = "Temps : " + str(int(temps_ecoule)) + "s"
		if has_node("EcranGameOver/Panel/VBoxContainer/LabelRecord"):
			$EcranGameOver/Panel/VBoxContainer/LabelRecord.text = texte_record

func _on_bouton_rejouer_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_bouton_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/Scenes/ui/menu_principal.tscn")
