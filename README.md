# just-a-game

Godot 4 prototype for a platformer with Celeste/Hollow Knight-inspired movement, a main menu, and tile-based levels.

## Controls
- Move: WASD / Arrow keys
- Jump: Space
- Dash: Shift
- Attack: J or K
- Toggle tile editor: E
- Select tile: 1 (Ground), 2 (Water), 3 (Fire)

## Notes
- Level editor is a basic tile painter (press E in level).
- Minigame portal loads a stub arcade scene; use the button to return.
- Combat is a simple melee hitbox versus a dummy enemy.
- PNG placeholder assets were removed; add your own textures at:
  - `assets/player.png`
  - `assets/enemy.png`
  - `assets/tiles/basic_tiles.png` (48x16, three 16x16 tiles: ground, water, fire)
