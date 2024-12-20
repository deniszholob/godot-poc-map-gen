extends CharacterBody2D

#region @export
@export
var WALK_SPEED: int = 100
@export
var RUN_SPEED: int = WALK_SPEED * 3
#endregion

#region var
var input: int = 2
#endregion

#region func: Overrides
func _physics_process(_delta):
	#var input_switch := Input.is_action_just_pressed('option');
	#if(input_switch):
		#input = ((input + 1) % 3) +1
		#print(input)
#
	#match input:
		#1:
			#read_input()
		#2:
			#read_input2()
		#3:
			#read_input3()
	read_input2()
#endregion

#region func: Private
func read_input3():
	var input_dir := Input.get_vector("move_left","move_right","move_up","move_down")
	var desired_velocity := input_dir * WALK_SPEED
	if(Input.is_action_pressed("boost")):
		desired_velocity = input_dir * RUN_SPEED
	var steering = desired_velocity - velocity
	velocity += steering / 5
	move_and_slide()

func read_input2():
	var input_dir = Input.get_vector("move_left","move_right","move_up","move_down")
	if(Input.is_action_pressed("boost")):
		velocity = input_dir * RUN_SPEED
	else:
		velocity = input_dir * WALK_SPEED
	move_and_slide()

func read_input():
	# Get the input direction and handle the movement/deceleration.
	var direction_y = Input.get_axis("move_up", "move_down")
	if direction_y:
		velocity.y = direction_y * WALK_SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, WALK_SPEED)

	var direction_x = Input.get_axis("move_left", "move_right")
	if direction_x:
		velocity.x = direction_x * WALK_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)

	move_and_slide()
#endregion
