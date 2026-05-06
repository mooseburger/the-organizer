extends CanvasLayer

@export var squiggle_scene: PackedScene

var current_edge: int = 0
var edge_ranges: Array[Vector2] = [
	Vector2(0, 0.25),
	Vector2(0.26, 0.5),
	Vector2(0.51, 0.75),
	Vector2(0.76, 1)
]

var active_squiggle_ratios: Array[float] = []
var min_ratio_gap: float = 0.05
var max_squiggles: int = 20
var total_squiggles: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StartSplashTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_splash_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var squiggle: Node2D = squiggle_scene.instantiate()

	# Choose a random location on Path2D.
	var squiggle_spawn_location = $SquigglePath/SquiggleSpawnLocation
	
	var spawn_edge = edge_ranges[current_edge % 4]
	var progress_ratio = find_clear_ratio(randf_range(spawn_edge.x, spawn_edge.y))
	if (progress_ratio < 0):
		return
	
	squiggle_spawn_location.progress_ratio = progress_ratio
	active_squiggle_ratios.append(progress_ratio)
	#print(len(active_squiggle_ratios))
	squiggle.tree_exiting.connect(func(): active_squiggle_ratios.erase(progress_ratio))
	current_edge += 1

	# Set the mob's position to the random location.
	squiggle.position = squiggle_spawn_location.position
	squiggle.set_edge(get_edge_from_position(squiggle_spawn_location.position))

	# Set the mob's direction perpendicular to the path direction.
	var direction = squiggle_spawn_location.rotation + PI / 2

	# Choose the velocity for the mob.
	var velocity = Vector2(600, 0.0)
	squiggle.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(squiggle)
	total_squiggles += 1
	
	#if (total_squiggles >= max_squiggles):
		#$StartSplashTimer.stop()

#func find_clear_ratio(ratio: float) -> float:
	#var candidate = ratio
	#for existing_ratio in active_squiggle_ratios:
		#if abs(candidate - existing_ratio) < min_ratio_gap:
			#candidate = existing_ratio + min_ratio_gap
			#candidate = find_clear_ratio(candidate)
			#candidate = fmod(candidate, 1.0)  # wrap around
			#return candidate
	#return candidate

func find_clear_ratio(ratio: float) -> float:
	var candidate = ratio
	var max_attempts = 100
	var attempts = 0
	var found_conflict = true
	
	while found_conflict and attempts < max_attempts:
		found_conflict = false
		for existing_ratio in active_squiggle_ratios:
			if abs(candidate - existing_ratio) < min_ratio_gap:
				candidate = fmod(existing_ratio + min_ratio_gap, 1.0)
				found_conflict = true
				break
		attempts += 1
	
	if attempts >= max_attempts:
		return -1
	
	return candidate
		
func get_edge_from_position(pos: Vector2) -> String:
	var rect = get_viewport().get_visible_rect().size
	var threshold = 10.0  # how close to the edge counts
	print(rect)
	print(pos)
	if pos.x <= threshold and pos.y >= threshold and pos.y <= rect.y - threshold:
		return "left"
	elif pos.x >= rect.x - threshold and pos.y >= threshold and pos.y <= rect.y - threshold:
		return "right"
	elif pos.y <= threshold:
		return "top"
	else:
		return "bottom"
