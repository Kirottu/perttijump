extends Spatial

onready var crosshair = $HUD/Crosshair

var target_scene = preload("res://Scenes/Target.tscn")

func _ready():
	set_positions()
	get_viewport().connect("size_changed", self, "_on_Viewport_size_changed")
	spawn_target(Vector3(0,13,20), 10)
	
func set_positions():
	crosshair.rect_position = Vector2((get_viewport().size.x - crosshair.rect_size.x) / 2, (get_viewport().size.y - crosshair.rect_size.y) / 2)

func _on_Viewport_size_changed():
	set_positions()

func spawn_target(position, value):
	var target = target_scene.instance()
	target.transform.origin = position
	target.value = value
	add_child(target)
