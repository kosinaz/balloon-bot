extends KinematicBody2D

func _physics_process(_delta):
#	if $"../BalloonBot".position.distance_to(position) < 150:
# warning-ignore:return_value_discarded
		$NavigationAgent2D.set_target_location($"../BalloonBot".global_position)
		move_and_slide(global_position.direction_to($NavigationAgent2D.get_next_location()) * 100)
		$Sprite.flip_h = $"../BalloonBot".position.x > position.x

func _on_Timer_timeout():
	pass
