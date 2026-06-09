# Unicorn Kittens — PC port (Godot 4)

A faithful PC port of the CityXen Commodore 64 game in [`../c64`](../c64), built with
**Godot 4.3** and GDScript.

> Sweet deliveries of justice! Fly Clicky the unicorn, catch falling goodies, deliver
> them to the Treats For Good People Center, rescue kittens, dodge the bad stuff — and
> when in trouble, **RAINBOW BARF** to nuke every bad thing on screen.

## Running

1. Open **Godot 4.3** (or newer 4.x).
2. *Import* this `pc/` folder (select the `project.godot` file).
3. Press **F5** / Play.

No external assets are needed — all art is drawn procedurally (matching the placeholder
status of the C64 version) and the sound effects are synthesised at startup.

## Controls

| Action | Keys |
|--------|------|
| Fly | Arrow keys or **WASD** |
| Fire / Rainbow Barf / Confirm | **Space**, **Z**, or **Enter** |
| Quit | **Esc** |

## How it plays

- Catch **cakes** and **candy** — carry up to **5** at once.
- Fly your load down to the green **Good People Center** to deliver and score (10 pts each).
- Rescue **kittens** for a 25 pt bonus (and a between-level tally parade).
- Dodge **tools, poo, and email** — each hit costs a heart. 5 hearts and you're out.
- **FIRE = RAINBOW BARF**: spends one goodie from your load to vaporise every bad thing
  on screen (5 pts each).
- Deliver enough goodies to clear the level; each level gets faster and meaner.

## Fidelity notes

The gameplay constants and logic mirror the C64 source one-to-one (`config.asm`,
`game_loop.asm`, `items.asm`, `unicorn.asm`, `barf.asm`, `util.asm`). Entity positions
are kept in the C64 sprite coordinate space so the original tuning numbers transfer
directly; `screen_pos()` maps them onto the 320x200 logical screen. The right-hand
columns (x >= 240) are a character-style HUD, exactly as on the C64. The fixed 60 Hz
`_physics_process` tick stands in for the C64's per-frame game loop.

Everything lives in `game.gd`; `main.tscn` is just a single `Node2D` running it.
