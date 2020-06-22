extends KinematicBody

const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 4.5

var dir = Vector3()

var energy = 5
var sprinting = false

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

onready var camera = $Rotation_Helper/Camera
onready var rotation_helper = $Rotation_Helper

var MOUSE_SENSITIVITY = 0.1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	if energy < 5 && !sprinting:
		energy += delta * Settings.energy_regen_factor
		
	if energy > 5:
		energy = 5
	
	sprinting = sprinting && energy > 0
	
	get_parent().get_node("HUD/energyBar").set_value(energy) #should only be after updating but das spaget

func process_input(delta):

	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	input_movement_vector.y += int(Input.is_action_pressed("movement_forward"))
	input_movement_vector.y -= int(Input.is_action_pressed("movement_backward"))
	input_movement_vector.x -= int(Input.is_action_pressed("movement_left"))
	input_movement_vector.x += int(Input.is_action_pressed("movement_right"))

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	sprinting = sprinting || Input.is_action_just_pressed("sprint") && energy > 2
	
	sprinting = sprinting && !Input.is_action_just_released("sprint")
	
	process_movement(delta)
	
func process_movement(delta):
	
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
		
	if is_on_floor() || Settings.can_steer_midair:
		hvel = hvel.linear_interpolate(target, accel * delta)
	
	if sprinting && is_on_floor():
		vel.x = hvel.x * Settings.SPRINT_MODIFIER
		vel.z = hvel.z * Settings.SPRINT_MODIFIER
		energy -= Settings.sprinting_tiring_factor * delta

	else:
		vel.x = hvel.x
		vel.z = hvel.z
	
	if energy < 0:
		energy = 0
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

#this comment is useless, just like our lazy artists
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
