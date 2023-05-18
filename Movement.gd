extends CharacterBody2D


@export var maxSpeed = 1000
@export var jumpPwr = 100
@export var friction = 200
@export var Accel = 1000

@onready var axis = Vector2.ZERO

func _physics_process(delta):
	move(delta)
	
func get_input_axis():
	axis.x = int(Input.is_action_pressed("Right" )) - int(Input.is_action_pressed("Left"))
	#axis.y = int(Input.is_action_pressed("Down" )) - int(Input.is_action_pressed("Up"))
	return axis.normalized()

func move(delta):
	axis = get_input_axis()
	
	if axis == Vector2.ZERO:
		apply_friction(friction * delta)
		
	else: 
		apply_movement(axis * Accel * delta) 
	move_and_slide()
	
func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
			
	else:
		velocity = Vector2.ZERO
		
func apply_movement(accel):
	velocity += accel
	velocity = velocity.limit_length(maxSpeed)
