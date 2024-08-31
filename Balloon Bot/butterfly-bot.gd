extends Area2D

func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property($".", "position", position + Vector2(50, 0), 2)
	tween.tween_property($".", "position", position - Vector2(50, 0), 2)
	tween.set_loops()

func _physics_process(_delta):
	$Sprite.flip_h = $"../BalloonBot".global_position.x > global_position.x


func _on_ButterflyBot_body_entered(body):
	if body.name != "BalloonBot":
		return
	$Sprite.flip_v = true
	var tween = get_tree().create_tween()
	tween.tween_property($".", "position", position + Vector2(0, 500), 4)
