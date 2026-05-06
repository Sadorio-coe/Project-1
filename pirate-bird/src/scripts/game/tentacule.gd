# On hérite du nouveau script parent au lieu de juste Area2D
extends "res://src/scripts/game/obstacle_base.gd"

func _ready():
	$AnimationPlayer.play("Entree")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("Idle")

func _process(delta):
	# On appelle le _process du parent pour gérer le mouvement de base (position.x -= vitesse * delta)
	super._process(delta) 
	
	# On garde la logique spécifique de l'animation de sortie de la tentacule
	if position.x < 70 and $AnimationPlayer.current_animation != "Sortie":
		disparaitre_et_supprimer()

func disparaitre_et_supprimer():
	$AnimationPlayer.play("Sortie")
	$CollisionPolygon2D.set_deferred("disabled", true)
	await $AnimationPlayer.animation_finished
	queue_free()

func _on_body_entered(body):
	if body.has_method("mourir"):
		body.mourir()

func _on_zone_score_body_entered(body):
	if body.name == "Naborim":
		get_tree().current_scene.ajouter_point()
		$ZoneScore.set_deferred("monitoring", false)
