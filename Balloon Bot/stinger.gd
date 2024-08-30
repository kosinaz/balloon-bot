extends Area2D

var velocity = Vector2()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += velocity * delta * 200


func _on_Stinger_body_entered(body):
	if body.name == "BalloonBot" and not name == "StingerBase":
		body.deflate()
	queue_free()
