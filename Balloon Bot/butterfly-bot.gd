extends Area2D

var fly_tween = null
var fall_tween = null

func _ready():
	fly_tween = get_tree().create_tween()
	fly_tween.tween_property($".", "position", position + Vector2(50, 0), 2)
	fly_tween.tween_property($".", "position", position - Vector2(50, 0), 2)
	fly_tween.set_loops()

func _physics_process(_delta):
	$Sprite.flip_h = $"../BalloonBot".global_position.x > global_position.x


func _on_ButterflyBot_body_entered(body):
	if body.name != "BalloonBot":
		return
	$Sprite.flip_v = true
	fall_tween = get_tree().create_tween()
	fall_tween.set_ease(Tween.EASE_IN)
	fall_tween.tween_property($".", "position", position + Vector2(0, 500), 2)
	fall_tween.tween_callback(self, "win")

func win():
	$"../CanvasLayer/VictoryLabel".show()
	$"../CanvasLayer/RestartButton".show()
	fly_tween.kill()
	fall_tween.kill()
	queue_free()
