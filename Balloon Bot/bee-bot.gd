extends KinematicBody2D

onready var target = global_position

func _physics_process(_delta):
	update_target()
	if global_position.distance_to(target) < 100:
		return
	$NavigationAgent2D.set_target_location(target)
# warning-ignore:return_value_discarded
	move_and_slide(global_position.direction_to($NavigationAgent2D.get_next_location()) * 100)
	$Sprite.flip_h = $"../BalloonBot".position.x > position.x

func update_target():
	if $"../BalloonBot".global_position.distance_to(global_position) > 500:
		return
	var new_target = $"../BalloonBot".global_position + Vector2(0, -32)
	$NavigationAgent2D.set_target_location(new_target)
	if not $NavigationAgent2D.is_target_reachable():
		return
	target = new_target

func _on_Timer_timeout():
	if target == global_position:
		return
	$RayCast2D.cast_to = target - global_position
	if $RayCast2D.get_collider() and not $RayCast2D.get_collider().name == "BalloonBot":
		return
	var stinger = $StingerBase.duplicate()
	stinger.name = "StingerClone"
	stinger.position = position + Vector2(0, 8)
	get_parent().add_child(stinger)
	stinger.velocity = global_position.direction_to(target + Vector2(0, -2))
	stinger.show()
