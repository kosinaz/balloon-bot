extends KinematicBody2D

var target = position

func _physics_process(_delta):
	update_target()
	if global_position.distance_to(target) < 100:
		return
	$NavigationAgent2D.set_target_location(target)
# warning-ignore:return_value_discarded
	move_and_slide(global_position.direction_to($NavigationAgent2D.get_next_location()) * 100)
	$Sprite.flip_h = $"../BalloonBot".position.x > position.x

func update_target():
	if $"../BalloonBot".position.distance_to(position) > 150:
		return
	var new_target = $"../BalloonBot".global_position + Vector2(0, -32)
	$NavigationAgent2D.set_target_location(new_target)
	if not $NavigationAgent2D.is_target_reachable():
		return
	target = new_target

func _on_Timer_timeout():
	pass
