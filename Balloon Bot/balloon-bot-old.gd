extends KinematicBody2D

var jump_power_initial = -500
var jump_power = 0
var jump_time_max = 0.3
var jump_timer = 0.0
var jump_velocity_step = 20
var is_jumping = false
var velocity = Vector2()
var speed = 400
var gravity = 2000.0
var flipped = true
var air = 1
var min_radius = 5
var min_height = 2
var min_x = 1
var min_y = 1
var max_radius = 13
var max_height = 2
var max_x = -3
var max_y = -7
var terminal_velocity = 1200
var last_position = Vector2()

func _physics_process(delta):
	print("last pos", position)
	if $"../TileMap".get_cellv($"../TileMap".world_to_map(position)) == 1:
		air = min(1, air + 0.01)
	$CollisionShape2D.shape.radius = min_radius + air * (max_radius - min_radius)
	$CollisionShape2D.shape.height = min_height + air * (max_height - min_height)
	$CollisionShape2D.position.x = min_x + air * (max_x - min_x)
	$CollisionShape2D.position.y = min_y + air * (max_y - min_y)
	$Balloon/Balloon.frame = 13 * air
	if not is_on_floor():
		if Input.is_action_pressed("ui_up") and air > 0:
			velocity.y += gravity / 3 * delta
		else:
			velocity.y += gravity * delta
	if Input.is_action_pressed("ui_up"):
		air = max(0, air - 0.002)
	
	
	if is_on_ceiling():
		velocity.y *= -1
	
	if is_on_floor():
		is_jumping = false
#		velocity.y = 0
#		position.y = round(position.y)
		
	if Input.is_action_pressed("ui_up") and is_on_floor() and air > 0:
		velocity.y = jump_power_initial
		
	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
	elif Input.is_action_pressed("ui_right"):
		velocity.x = speed
	else:
		velocity.x = 0
		
	velocity.y = min(velocity.y, terminal_velocity)
	# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP)
	print("new pos", position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$"../CanvasLayer/ProgressBar".value = air
	if Input.is_action_pressed("ui_right"):
		$AnimationPlayer.play("run" if is_on_floor() else "idle")
		if flipped:
			scale.x = -1
			flipped = false
	elif Input.is_action_pressed("ui_left"):
		$AnimationPlayer.play("run" if is_on_floor() else "idle")
		if not flipped:
			scale.x = -1
			flipped = true
	elif Input.is_action_pressed("ui_up"):
		$AnimationPlayer.play("idle")
	else:
		$AnimationPlayer.play("idle")
