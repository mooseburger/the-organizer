extends Node2D

signal squiggle_left

@export var linear_velocity: Vector2 = Vector2(300.0, 0.0)

@export var time: float = 0.0
@export var amplitude: float = 5.0
@export var frequency: float = 5.0
@export var speed: float = 17.0
@export var segments: int = 200
@export var wave_width: float = 800.0
@export var line_color: Color = Color.WHITE
@export var line_width: float = 2.0

func _ready() -> void:
	$SquiggleNotifier.rect = Rect2(
		-wave_width / 2.0, -amplitude,
		wave_width, amplitude * 2.0
	)

func _process(delta: float) -> void:
	position += linear_velocity * delta
	time += delta
	queue_redraw()

func _draw() -> void:
	var points: Array[Vector2] = []
	for i in range(segments + 1):
		var t := float(i) / float(segments)
		var x := t * wave_width - wave_width / 2.0
		var y := sin(t * frequency * TAU + time * speed) * amplitude
		points.append(Vector2(x, y))
	draw_polyline(points, line_color, line_width, true)

func set_edge(edge: String) -> void:
	#print(edge)
	match edge:
		"left":
			rotation = 0.0
			linear_velocity = Vector2(speed, 0.0)
		"right":
			rotation = 0.0
			linear_velocity = Vector2(-speed, 0.0)
		"top":
			rotation = PI / 2.0
			linear_velocity = Vector2(0.0, speed)
		"bottom":
			rotation = PI / 2.0
			linear_velocity = Vector2(0.0, -speed)


func _on_squiggle_notifier_screen_exited() -> void:
	#print("squiggle exited")
	#squiggle_left.emit(self)
	queue_free()
