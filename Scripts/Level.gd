extends Spatial

onready var crosshair = $HUD/Crosshair

func _ready():
	set_positions()
	get_viewport().connect("size_changed", self, "_on_Viewport_size_changed")
	
func set_positions():
	crosshair.rect_position = Vector2((get_viewport().size.x - crosshair.rect_size.x) / 2, (get_viewport().size.y - crosshair.rect_size.y) / 2)

func _on_Viewport_size_changed():
	set_positions()
