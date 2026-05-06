extends Area2D
class_name ObstacleBase

# Cette variable sera héritée par tous les enfants (tentacules, palmiers, etc.)
var vitesse = 0 

func _process(delta):
	# Tous les obstacles reculent vers la gauche de la même manière
	position.x -= vitesse * delta
	
	# Sécurité par défaut : détruire l'obstacle s'il sort complètement de l'écran à gauche
	# (On met -200 pour s'assurer qu'il est bien hors de vue)
	if position.x < -200:
		queue_free()
