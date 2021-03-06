extends KinematicBody

onready var score_label = get_parent().get_node("HUD/Score")
onready var energy_bar = get_parent().get_node("HUD/Energy")

var vel = Vector3()
var dir = Vector3()

var score
var energy
var sprinting = false

onready var camera = $Rotation_Helper/Camera
onready var rotation_helper = $Rotation_Helper

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_score(0, true)
	update_energy(5, true)

func _physics_process(delta):
	process_input(delta)
	if energy < 5 && !sprinting:
		update_energy(delta * Settings.energy_regen_factor, false)
	
	sprinting = sprinting && energy > 0


func process_input(delta):
	var cam_xform = camera.get_global_transform()
	var input_movement_vector = Vector2(int(Input.is_action_pressed("movement_right")) - int(Input.is_action_pressed("movement_left")), int(Input.is_action_pressed("movement_forward")) - int(Input.is_action_pressed("movement_backward"))).normalized()
	dir = Vector3(cam_xform.basis.x * input_movement_vector.x - cam_xform.basis.z * input_movement_vector.y)

	if Input.is_action_just_pressed("movement_jump") && is_on_floor():
		vel.y = Settings.jump_speed
	
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	print(Input.get_mouse_mode())
	
	sprinting = sprinting || Input.is_action_just_pressed("sprint") && energy > 2
	
	sprinting = sprinting && !Input.is_action_just_released("sprint")
	
	process_movement(delta)
	
func process_movement(delta):
	
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * Settings.gravity

	var hvel = vel
	hvel.y = 0

	var target = dir * Settings.max_speed

	var accel = Settings.accel if dir.dot(hvel) > 0 else Settings.deaccel
		
	if is_on_floor() || Settings.can_steer_midair:
		hvel = hvel.linear_interpolate(target, accel * delta)
	
	if sprinting && is_on_floor():
		vel.x = hvel.x * Settings.SPRINT_MODIFIER
		vel.z = hvel.z * Settings.SPRINT_MODIFIER
		update_energy(-Settings.sprinting_tiring_factor * delta, false)
	else:
		vel = Vector3(hvel.x, vel.y, hvel.z)
	
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(Settings.max_slope_angle))

#this comment is useless, just like our lazy artists
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * Settings.mouse_sensitivity * -1))
		self.rotate_y(deg2rad(event.relative.x * Settings.mouse_sensitivity * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot

func update_score(value, absolute):
	if absolute:
		score = value
	else:
		score += value
	
	score_label.text = str(score)

func update_energy(value, absolute):
	if absolute:
		energy = value
	else:
		energy += value
	
	energy = clamp(energy, 0, 5)
	energy_bar.set_value(energy)
