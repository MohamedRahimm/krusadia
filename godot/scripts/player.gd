extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -350.0
const WALL_SLIDE_SPEED = 50.0

# --- Coyote Time ---
const COYOTE_TIME_DURATION = 0.12 # Jump forgiveness time
var coyote_timer = 0.0            # Countdown timer for coyote jump

var current_direction = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_on_wall() and not is_on_floor():
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			$JumpSfx.play()
		elif is_on_wall() and !is_on_floor():
			current_direction *= -1
			velocity.y = JUMP_VELOCITY / 3 * 2
			$JumpSfx.play()
			
		
		velocity.x = SPEED * current_direction
		$AnimatedSprite2D.play("run")
		if current_direction == -1:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("idle")
		velocity.x = SPEED * current_direction

	if not is_on_floor():
		$AnimatedSprite2D.play("jump")

	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		print('changing scene to next level')
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/level_2.tscn")
