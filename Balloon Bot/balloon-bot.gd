extends KinematicBody2D

## The maximum horizontal speed of the player running in px/s.
## This is also the maximum speed player can acccelerate to when jumping.
var max_speed: float = 300.0

## The acceleration of the player when running on ground in px/s².
var acceleration: float = 1250.0

## The deceleration (braking) of the player when running on ground in px/s².
var deceleration: float = 2500.0

## The acceleration of the player when moving in the air in px/s².
var air_acceleration: float = 1250.0

## The deceleration (braking) of the player when moving in the air in px/s².
var air_deceleration: float = 2500.0

## The vertical velocity of the player when jumping in px/s.
## This determines how high the player can jump, depending on the gravity multiplier.
var jump_velocity: float = 600.0

## The default gravity multiplier of the player. It's simply multiplying the gravity vector
## with this value. It's affected by the global gravity and mofidiers, like Area2D regions.
## This value is also used when falling without jumping.
var gravity_multiplier: float = 1.0

## The gravity multiplier of the player when falling after jumping.
## This multiplier is applied on top of the standard gravity_multiplier.
## This is intended to make the player fall faster after the upward phase of jumping
## is over.
var gravity_fall_multiplier: float = 2.5

## The maximum vertical velocity (px/s) of the player when falling (due to jumping or not).
## This can also be used to simulate gliding when set to a low value.
var vertical_terminal_velocity: float = 600.0

## The multiplier of the player's vertical velocity applied when releasing the jump button.
## This allows the player to release jump button earlier to make the jump shorter.
## In other words, the maximum jump height can be achieved by holding the jump button.
## When set to 1.0, the release of the jump button won't affect the jump height.
## Setting this to 0.0, will make the player instantly start falling.
var jump_release_stop_multiplier: float = 0.1

## The coyote time duration in seconds.
## The player will be able to jump for this extra amount of time after
## stopped touching the ground. It reduces the risk of the player falling off the platform
## when intended to jump.
var coyote_duration: float = 0.1

## Display the coyote timer debug label.
var debug_coyote: bool = false

## The jump buffer duration in seconds.
## If the player presses the jump button before the character touches the ground, the
## jump buffer will be activated. If the character touches the ground within the time
## specified by this value, the jump will happen automatically.
## This is to avoid situations where the player presses "jump" too early. This simply
## captures the intent of jumping for the specified amount of time.
var jump_buffer_duration: float = 0.4

## Display the jump buffer timer debug label.
var debug_jump_buffer: bool = false


var is_jumping: bool = false ## Is the reason for the player to be in the air due to a jump?
var was_on_floor: bool = false ## Was the player on the floor in the previous (physics) frame?
var is_coyote: bool = false ## Is the coyote time timer active?
var is_jump_buffer: bool = false ## Is the jump buffer timer active?

onready var coyote_timer: Timer = $CoyoteTimer
onready var jump_buffer_timer: Timer = $JumpBufferTimer

# Animation
onready var sprite: AnimatedSprite = $Balloon/Balloon
onready var animation_player: AnimationPlayer = $AnimationPlayer
var facing_right_x_offset: float = 0 ## The offset of the sprite when facing right - due to non-centered graphics.
var facing_left_x_offset: float = 0 ## The offset of the sprite when facing left - due to non-centered graphics.
var facing_right: bool = true ## Is the player facing right? (sprite flipping)

# Particle
onready var run_particles: CPUParticles2D = $RunParticles
onready var jump_particles: CPUParticles2D = $JumpParticles
onready var land_particles: CPUParticles2D = $JumpParticles

# Sounds
onready var jump_player: AudioStreamPlayer2D = $JumpPlayer
onready var land_player: AudioStreamPlayer2D = $LandPlayer
onready var step_player: AudioStreamPlayer2D = $StepPlayer
var is_playing_step: bool = false ## Is the step sound already playing?

# Debug
onready var coyote_label: Label = $CoyoteDebug
onready var jump_buffer_label: Label = $JumpBufferDebug

# Signals
#signal jumped ## Emitted when the player jumps.
#signal landed ## Emitted when the player lands.
#signal coyote_started ## Emitted when the coyote timer starts.
#signal coyote_stopped ## Emitted when the coyote timer stops not used.
#signal coyote_used ## Emitted when the player jumps due to the coyote timer.
#signal jump_buffer_started ## Emitted when the jump buffer timer starts.
#signal jump_buffer_stopped ## Emitted when the jump buffer timer stops not used.
#signal jump_buffer_used ## Emitted when the player jumps due to the jump buffer timer.

# Godot 3.5
var global_gravity = 1250
var velocity = Vector2()
var flipped = true

# Custom
var air = 1
var min_radius = 5
var min_height = 2
var min_x = 1
var min_y = 1
var max_radius = 13
var max_height = 2
var max_x = -3
var max_y = -7

func _ready():
	# Engine.time_scale = 0.2
	# Capture the x offset of the sprite in case the player graphics
#	# is not in the center of the sprite.
#	facing_right_x_offset = sprite.position.x
#	facing_left_x_offset = -sprite.position.x

#	jumped.connect(_on_jumped, CONNECT_DEFERRED)
#	landed.connect(_on_landed, CONNECT_DEFERRED)

	if debug_coyote:
		coyote_label.visible = false
#		coyote_started.connect(_on_coyote_started_debug, CONNECT_DEFERRED)
#		coyote_stopped.connect(_on_coyote_stopped_debug, CONNECT_DEFERRED)
#		coyote_used.connect(_on_coyote_used_debug, CONNECT_DEFERRED)

	if debug_jump_buffer:
		jump_buffer_label.visible = false
#		jump_buffer_started.connect(_on_jump_buffer_started_debug, CONNECT_DEFERRED)
#		jump_buffer_stopped.connect(_on_jump_buffer_stopped_debug, CONNECT_DEFERRED)
#		jump_buffer_used.connect(_on_jump_buffer_used_debug, CONNECT_DEFERRED)


func _physics_process(delta):
	
	# Custom
	if $"../TileMap".get_cellv($"../TileMap".world_to_map(position)) == 1:
		air = min(1, air + 0.01)
	$CollisionShape2D.shape.radius = min_radius + air * (max_radius - min_radius)
	$CollisionShape2D.shape.height = min_height + air * (max_height - min_height)
	$CollisionShape2D.position.x = min_x + air * (max_x - min_x)
	$CollisionShape2D.position.y = min_y + air * (max_y - min_y)
	$Balloon/Balloon.frame = 13 * air
	if Input.is_action_pressed("jump"):
		air = max(0, air - 0.002)
	if is_on_ceiling():
		velocity.y *= -0.1
	$"../CanvasLayer/ProgressBar".value = air

	# On ground
	if is_on_floor():
		is_jumping = false
		if not was_on_floor:
#			landed.emit()
			_on_landed()

		if is_jump_buffer and not was_on_floor:
			is_jump_buffer = false
			jump_buffer_timer.stop()
#			jump_buffer_used.emit()
			jump()
		elif Input.is_action_just_pressed("jump"):
			jump()

		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		if direction > 0:
			facing_right = true
		elif direction < 0:
			facing_right = false

		was_on_floor = true

	# In air
	else:
		var gravity = get_gravity() * gravity_multiplier

		if was_on_floor and not is_jumping:
			start_coyote(delta)

		if Input.is_action_just_pressed("jump"):
			if is_coyote:
				is_coyote = false
				coyote_timer.stop()
#				coyote_used.emit()
				jump()
			elif not is_jump_buffer:
				start_jump_buffer()

		# Add extra gravity when falling
		if is_jumping and velocity.y > 0:
			velocity += gravity * gravity_fall_multiplier * delta
		else:
			velocity += gravity * delta

		# Released jump - increase gravity
		if velocity.y < 0 and Input.is_action_just_released("jump"):
			velocity.y = velocity.y * jump_release_stop_multiplier

		# Limit vertical velocity
		velocity.y = min(velocity.y, vertical_terminal_velocity)

		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = move_toward(velocity.x, direction * max_speed, air_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, air_deceleration * delta)
		if direction > 0:
			facing_right = true
		elif direction < 0:
			facing_right = false

		was_on_floor = false
		
		if $"../TileMap".world_to_map(position).x < -55:
			$"../CanvasLayer/VictoryLabel".show()
			$"../CanvasLayer/RestartButton".show()
		if $"../TileMap".world_to_map(position).y > 70:
# warning-ignore:return_value_discarded
			get_tree().reload_current_scene()

# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP)

func _process(_delta):
	# Animate and adjust the sprite

	# Flip the sprite depending on the facing direction
#	sprite.flip_h = not facing_right
#	sprite.position.x = facing_right_x_offset if facing_right else facing_left_x_offset
	if facing_right:
		if flipped:
			scale.x = -1
			flipped = false
	else:
		if not flipped:
			scale.x = -1
			flipped = true

	# Update the animations and run effects
	run_particles.emitting = false
	if is_on_floor():
		if velocity.x != 0:
#			sprite.play("run")
			animation_player.play("run")
			run_particles.emitting = true
			if not is_playing_step:
				step_player.pitch_scale = rand_range(0.85, 1.15)
				step_player.play()
				is_playing_step = true
		else:
#			sprite.play("idle")
			animation_player.play("idle")

	else:
		if velocity.y < 0:
#			sprite.play("jump")
			animation_player.play("idle")
		else:
#			sprite.play("fall")
			animation_player.play("idle")

	if debug_coyote and is_coyote:
		coyote_label.text = "C: %.3fs" % coyote_timer.time_left

	if debug_jump_buffer and is_jump_buffer:
		jump_buffer_label.text = "J: %.3fs" % jump_buffer_timer.time_left

# Initiate jump if pressed jump button
func jump():
	if air == 0:
		return
	velocity.y = -jump_velocity * (air / 2 + 0.5)
	is_jumping = true
#	jumped.emit()
	_on_jumped()

func start_coyote(delta):
#	print("Starting coyote with duration of %.3fs" % coyote_duration)
#	print("Delta is %.3fs" % delta)
	var time_left = coyote_duration - delta
#	print("Time left is %.3fs" % time_left)
	coyote_timer.start(time_left)
	is_coyote = true
#	coyote_started.emit()

func _on_coyote_timer_timeout():
	is_coyote = false
#	coyote_stopped.emit()

func start_jump_buffer():
	jump_buffer_timer.start(jump_buffer_duration)
	is_jump_buffer = true
#	jump_buffer_started.emit()

func _on_jump_buffer_timer_timeout():
	is_jump_buffer = false
#	jump_buffer_stopped.emit()


func _on_step_player_finished():
	is_playing_step = false

func _on_jumped():
	jump_particles = jump_particles.duplicate()
	get_parent().add_child(jump_particles)
	jump_particles.position = position + Vector2(0, 3)
	jump_particles.emitting = true
#	animation_player.play("jump")
	animation_player.play("idle")
	jump_player.pitch_scale = rand_range(0.8, 1.2)
	jump_player.play()

func _on_landed():
	land_particles = land_particles.duplicate()
	get_parent().add_child(land_particles)
	land_particles.position = position + Vector2(0, 5)
	land_particles.emitting = true
#	animation_player.play("land")
	animation_player.play("idle")
	land_player.pitch_scale = rand_range(0.8, 1.2)
	land_player.play()

func _on_coyote_started_debug():
	coyote_label.text = "C: %.3fs" % coyote_timer.time_left
	coyote_label.visible = true

func _on_coyote_stopped_debug():
	coyote_label.text = "C: -"
	coyote_label.visible = false

func _on_coyote_used_debug():
	coyote_label.text = "C: U"
	coyote_label.visible = false

func _on_jump_buffer_started_debug():
	jump_buffer_label.text = "J: %.3fs" % jump_buffer_timer.time_left
	jump_buffer_label.visible = true

func _on_jump_buffer_stopped_debug():
	jump_buffer_label.text = "J: -"
	jump_buffer_label.visible = false

func _on_jump_buffer_used_debug():
	jump_buffer_label.text = "J: U"
	jump_buffer_label.visible = false
	
func get_gravity():
	return Vector2(0, global_gravity)
	
func deflate():
	air = max(0, air - 0.1)
	$"../CanvasLayer/AnimationPlayer".play("deflate")

func _on_RestartButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
