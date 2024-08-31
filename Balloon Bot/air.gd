extends Node2D

func _physics_process(_delta):
	if $"../BalloonBot" and global_position.distance_to($"../BalloonBot".global_position) < 10:
		$"../BalloonBot".air = min(1, $"../BalloonBot".air + 0.01)
