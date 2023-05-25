extends CharacterBody2D

#Variables

@export var SPEED = 300.0
@export var canDash = true
@export var JUMP_VELOCITY = -400.0
@export var plrVelocity = 300
#Added jump velocity
@export var jumpVelocity = 500
#@export var maxJumps = 2
@export var dashPwr = 400
var playerInput = Vector2(0,0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D
#Not sure if this does what I want it to do vvv
#@onready var thePire = get_node("Area2D")

#Troubleshooting
#Game thinks the player is on the floor even when jumping
#Walking in the air makes you float
#Unable to move while jumping 



enum State
{
	IDLE,
	MOVING,
	JUMPING,
	ATTACKING,
	DASHING,
	FALLING
}

var currentState: State

func processFalling():
	pass

func processDashing():
	pass
	

func enterDashing():
	animated_sprite.animation = "dash"
	canDash = false
	$CPUParticles2D.restart()
	$DashTimer.start()
	if(playerInput.x >= 0):
		velocity.x = 400
		$AnimatedSprite2D.flip_h = false
	else: 
		velocity.x = -400
		$AnimatedSprite2D.flip_h = true
	velocity.y = 0
	currentState = State.DASHING
	
		


func processAttacking():
	pass
	
func enterAttacking():
	currentState = State.ATTACKING
	#$CollisionShape2D.disabled = false
	animated_sprite.animation = "attacking"
	velocity.x = 0
	

func enterIdle():
	if(is_on_floor()):
		velocity.x = 0
	animated_sprite.animation = "idle"
	animated_sprite.play()
	currentState = State.IDLE
	#maxJumps = 2


func processIdle(delta):
	if(not is_on_floor()):
		enterJump()
		return
	if(playerInput.x != 0):
		enterMove()
	elif(playerInput.y != 0):
		enterJump()
	elif(Input.is_action_just_pressed("Attack")):
		enterAttacking()
	else:
		currentState = State.IDLE 


func enterMove():
	animated_sprite.animation = "running"
	animated_sprite.play()
	currentState = State.MOVING


func processMove(delta):
	if(playerInput.y != 0 || !is_on_floor()):
		enterJump()
		return
	if(Input.is_action_just_pressed("Attack")):
		enterAttacking()
		return	
	if (Input.is_action_just_pressed("Dash")):
		enterDashing()
		return
	if(Input.is_action_pressed("Right")):
		velocity.x = plrVelocity 
		$AnimatedSprite2D.flip_h = false
	elif (Input.is_action_pressed("Left")):
		velocity.x = -plrVelocity 
		$AnimatedSprite2D.flip_h = true 
	
	else:
		enterIdle()

func enterJump(doJump = true):
	if(is_on_floor()):
		$Yump.play()
	if(Input.is_action_just_pressed("Jump")):
		velocity.y -= jumpVelocity
		#maxJumps -= 1
	animated_sprite.animation = "jumping"
	animated_sprite.play()
	currentState = State.JUMPING

func processJump(delta):
	velocity.y += gravity * delta
	if(is_on_floor()):
		enterIdle()
	elif(playerInput.y != 0 and !is_on_floor()):
		if(Input.is_action_pressed("Right")):
			velocity.x = plrVelocity 
		elif(Input.is_action_pressed("Left")):
			velocity.x = -plrVelocity
		enterJump()
	elif(Input.is_action_just_pressed("Dash") && canDash):
		enterDashing()

func _ready():
	enterIdle()



func getPlayerInput():
	playerInput = Vector2()
	playerInput.x = Input.get_axis("Left","Right")
	if(Input.is_action_just_pressed("Jump") and is_on_floor()):
		playerInput.y = 1


func _physics_process(delta):
	getPlayerInput()
	if(currentState == State.IDLE):
		processIdle(delta)
	elif(currentState == State.MOVING):
		processMove(delta)
	elif(currentState == State.JUMPING):
		processJump(delta)
	move_and_slide()
#
#
#
#	else:
#		if(velocity.x == 0):
#			
#		else:
#			animated_sprite.animation = "running"
#
#	# Handle Jump.
#	if Input.is_action_just_pressed("Jump") and is_on_floor():
#		velocity.y = JUMP_VELOCITY
#		animated_sprite.animation = "jumping"
#		$AnimatedSprite2D.set_flip_h(false)
#
#	# Get the input direction and handle the movement/deceleration.
#	# As good practice, you should replace UI actions with custom gameplay actions.
#	var direction = Input.get_axis("Left", "Right")
#	if direction:
#		velocity.x = direction * SPEED
#	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED)
#
#	move_and_slide()

#maxJumps > 0 and 

func _on_animated_sprite_2d_animation_finished():
	if($AnimatedSprite2D.animation ==  "attacking"):
		#$CollisionShape2D.disabled = true
		enterIdle()
	
	


func _on_dash_timer_timeout():
	$DashCooldown.start()
	enterIdle()
	


func _on_dash_cooldown_timeout():
	canDash = true
