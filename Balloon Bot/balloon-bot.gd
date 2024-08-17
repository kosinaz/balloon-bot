extends KinematicBody2D

var jump_power_initial = -200
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
var min_radius = 3
var min_height = 6
var min_y = 1
var max_radius = 7
var max_height = 8
var max_y = -4

func _physics_process(delta):
	$CollisionShape2D.shape.radius = min_radius + air * (max_radius - min_radius)
	$CollisionShape2D.shape.height = min_height + air * (max_height - min_height)
	$CollisionShape2D.position.y = min_y + air * (max_y - min_y)
	$Balloon/Balloon.frame = 10 * air
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_ceiling():
		jump_timer = jump_time_max
	
	if is_on_floor():
		jump_timer = 0.0
		is_jumping = false
	else:
		jump_timer += delta
		
	if Input.is_action_pressed("ui_up") and is_on_floor() and air > 0:
		air = max(0, air - 0.01)
		jump_timer = 0.0
		is_jumping = true
		velocity.y = jump_power_initial
		jump_power = jump_power_initial
	elif Input.is_action_pressed("ui_up") and is_jumping and jump_timer < jump_time_max and air > 0:
		air = max(0, air - 0.01)
		jump_power -= jump_velocity_step
		velocity.y = jump_power
		
	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
	elif Input.is_action_pressed("ui_right"):
		velocity.x = speed
	else:
		velocity.x = 0
		
	# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
		

func _input(event):
	if event.is_action_released("ui_up") and is_jumping:
		jump_timer = jump_time_max
