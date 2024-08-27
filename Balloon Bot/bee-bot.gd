extends KinematicBody2D

func _physics_process(_delta):
	if $"../BalloonBot".position.distance_to(position) < 150:
# warning-ignore:return_value_discarded
		move_and_slide(($"../BalloonBot".position - position).normalized() * 100, Vector2.UP)
		$Sprite.flip_h = $"../BalloonBot".position.x > position.x

func _on_Timer_timeout():
	pass
