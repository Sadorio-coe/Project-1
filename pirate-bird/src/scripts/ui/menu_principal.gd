extends Control

# Chemin vers la scène de jeu (Utilisation de l'UID pour plus de sécurité)
# L'UID de le_monde.tscn est : uid://c0plmvgjb37vr
var scene_jeu = "uid://c0plmvgjb37vr" 
var chemin_sauvegarde = "user://historique_pirate.save"

func _ready():
	get_tree().paused = false
	if has_node("VBoxContainer/BoutonJouer"):
		$VBoxContainer/BoutonJouer.grab_focus()
		
	if has_node("PopupScores"):
		$PopupScores.visible = false
	
	print("--- Menu Principal Prêt ---")

# --- FONCTION JOUER ---
func _on_bouton_jouer_pressed():
	# Utilise la variable scene_jeu qui contient maintenant l'UID
	get_tree().change_scene_to_file(scene_jeu)

# --- FONCTION PARAMETRES ---
func _on_bouton_parametres_pressed():
	print("Clic : Paramètres")

# --- FONCTION SCORES ---
func _on_bouton_score_pressed():
	print("1. Signal du bouton SCORE reçu !")
	
	if has_node("PopupScores"):
		$PopupScores.visible = true
		print("2. PopupScores trouvé et affiché.")
		actualiser_la_liste_scores()
	else:
		print("ERREUR : Le nœud PopupScores est introuvable dans la scène !")

# --- FONCTION RETOUR ---
func _on_bouton_retour_pressed():
	print("Clic : Retour au menu")
	if has_node("PopupScores"):
		$PopupScores.visible = false

# --- LOGIQUE D'AFFICHAGE ---
func actualiser_la_liste_scores():
	print("3. Début de l'actualisation de la liste...")
	
	var conteneur = get_node_or_null("PopupScores/ScrollContainer/ListeScores")
	
	if conteneur == null:
		print("ERREUR CRITIQUE : Le chemin 'PopupScores/ScrollContainer/ListeScores' n'existe pas !")
		return
	
	print("4. Conteneur de liste trouvé avec succès.")

	# Nettoyage des anciens labels
	for enfant in conteneur.get_children():
		enfant.queue_free()
	
	# Chargement des données
	var scores = []
	if FileAccess.file_exists(chemin_sauvegarde):
		var fichier = FileAccess.open(chemin_sauvegarde, FileAccess.READ)
		if fichier:
			scores = fichier.get_var()
			fichier.close()
			print("5. Fichier de sauvegarde trouvé. Nombre de scores : ", scores.size())
	else:
		print("5. Aucun fichier de sauvegarde trouvé.")
	
	# Création des labels pour le Top 50
	var rang = 1
	for s in scores:
		var label = Label.new()
		label.text = str(rang) + ".   " + str(s) + " points"
		
		# Petit bonus visuel pour le podium
		if rang == 1: label.modulate = Color.GOLD
		elif rang == 2: label.modulate = Color.SILVER
		elif rang == 3: label.modulate = Color(0.8, 0.5, 0.2) # Bronze
		
		conteneur.add_child(label)
		rang += 1
	
	print("6. Affichage des scores terminé.")

# --- FONCTION QUITTER ---
func _on_bouton_quitter_pressed():
	get_tree().quit()
