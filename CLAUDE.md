# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"The Organizer" — a Godot 4.6 game project (Forward+ renderer, Jolt 3D physics). Gameplay code is GDScript; despite `[dotnet] assembly_name`, no C# files are present yet. Entry point: `main.tscn` (configured in `project.godot`). The `.godot/` cache is gitignored — Godot regenerates it on import.

## Running / editing

There is no CLI build step or test suite. Open `project.godot` in the Godot 4.6 editor and run with F5 (`main.tscn` is the main scene). To run from CLI: `godot --path . --main-scene res://main.tscn` (or `godot -e --path .` to open the editor).

## Architecture

Two largely independent layers currently live under `Main`:

1. **`StartScreen`** (`start_screen.gd`, CanvasLayer) — fully wired and currently the only thing that does anything. A `StartSplashTimer` (0.1s) repeatedly spawns `start_squiggle.tscn` instances along a rectangular `Path2D` (`SquigglePath`) that traces the viewport edges. `current_edge` cycles 0..3 to round-robin spawn locations across the four edges (`edge_ranges` partitions `progress_ratio` into quarters). `find_clear_ratio` enforces a `min_ratio_gap` between concurrent squiggles by walking forward along the path; `active_squiggle_ratios` is kept in sync via each squiggle's `tree_exiting` signal.

2. **`start_squiggle.gd`** (Node2D) — a self-drawing animated sine wave (`_draw` builds a polyline each frame from `segments+1` points; `time` advances in `_process`). `set_edge(edge)` rotates the wave and sets `linear_velocity` so squiggles travel inward from the edge they spawned on. A child `VisibleOnScreenNotifier2D` (`SquiggleNotifier`) frees the node once it leaves the screen — its `Rect2` is sized in `setup_notifier()` (called via `call_deferred` so the node is in-tree first).

3. **`main.gd`** — **scaffolding only, not yet wired up.** It references `$Music`, `$Player`, `$StartTimer`, `$HUD`, `$MobTimer`, `$ScoreTimer`, `$MobPath/MobSpawnLocation`, `$StartPosition`, and `$DeathSound`, none of which exist in `main.tscn`. Calling `new_game()` or `game_over()` will crash. This is a Godot "Dodge the Creeps"–style template waiting for those nodes/scenes to be added; treat it as a stub when modifying the start screen.

### Coordinate / signal gotchas

- `start_screen.gd:39` connects `tree_exiting` with a closure capturing `progress_ratio`, but `start_squiggle.gd:58` has the `squiggle_left.emit(self)` line commented out — cleanup currently relies on `tree_exiting` from `queue_free()`, not the custom signal. The `_on_start_squiggle_squiggle_left` handler is dead code.
- `start_squiggle.gd:44` sets `linear_velocity = Vector2(speed, 0.0)` using the `speed` export (default 17.0), which conflicts with the caller in `start_screen.gd:51` that sets velocity to `Vector2(600, 0.0)` *before* `set_edge` is called — `set_edge` overwrites it. If a squiggle looks slow, that's why.
- The squiggle in `main.tscn:20` is a leftover instance under `StartScreen` (alongside the script-spawned ones) and has its own `SquiggleNotifier` connected directly in the scene.
