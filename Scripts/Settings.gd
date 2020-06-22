extends Node

const SPRINT_MODIFIER = 1.1				#with how much pertti's speed is multiplied per physics frame while sprinting
const energy_regen_factor = 2 			#how much health pertti should gain per second while sprinting
const sprinting_tiring_factor = 5 		#how much health pertti should lose per second while sprinting
const sprinting_start_treshold = 2 		#how much energy is needed in order to start sprinting
const can_steer_midair = false			#wether pertti can sprint while falling or not

const gravity = -24.8
const max_speed = 20
const jump_speed = 18
const accel = 4.5
const deaccel = 16
const max_slope_angle = 40
const mouse_sensitivity = 0.1
