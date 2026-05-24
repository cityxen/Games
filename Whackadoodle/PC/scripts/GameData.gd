extends Node

# ─── Enums ───────────────────────────────────────────────────────────────────

enum Mode { EASY, NORMAL, HARD }

# ─── Doodle definitions ───────────────────────────────────────────────────────
# Indices 0-3 are GOOD (player should NOT hit them)
# Indices 4-7 are BAD  (player SHOULD hit them)

const DOODLE_COUNT = 8
const DOODLE_IS_BAD := [false, false, false, false, true, true, true, true]
const DOODLE_PATHS := [
	"res://images/doodle-happyface.png",   # 0 - Happy Face (good)
	"res://images/doodle-tao.png",         # 1 - Yin-Yang   (good)
	"res://images/doodle-heart.png",       # 2 - Heart      (good)
	"res://images/doodle-star.png",        # 3 - Star       (good)
	"res://images/doodle-rads.png",        # 4 - RAD        (bad)
	"res://images/doodle-skull.png",       # 5 - Skull      (bad)
	"res://images/doodle-poo.png",         # 6 - Poo        (bad)
	"res://images/doodle-madface.png",     # 7 - Frown      (bad)
]

# ─── Button definitions ───────────────────────────────────────────────────────

const BUTTON_COUNT = 5
const BUTTON_NAMES  := ["Red", "Green", "Yellow", "Blue", "White"]
const BUTTON_PATHS  := [
	"res://images/button-red.png",
	"res://images/button-green.png",
	"res://images/button-yellow.png",
	"res://images/button-blue.png",
	"res://images/button-white.png",
]
const BUTTON_COLORS := [
	Color(0.90, 0.25, 0.25),   # Red
	Color(0.25, 0.85, 0.25),   # Green
	Color(0.95, 0.90, 0.20),   # Yellow
	Color(0.25, 0.45, 1.00),   # Blue
	Color(0.95, 0.95, 0.95),   # White
]
# Keyboard keys: A S D F G  (left to right across home row)
const BUTTON_KEYS := [KEY_A, KEY_S, KEY_D, KEY_F, KEY_G]

# ─── Timing (converting C64 60 Hz frames to seconds) ─────────────────────────

const FRAMES := 60.0
const MESSAGE_DURATION := 80.0  / FRAMES   # ~1.33 s  (timer 3 = 80 frames)
const GETREADY_DURATION := 120.0 / FRAMES  # ~2.0 s   (two pause3 calls)

const SPEED_INITIAL_FRAMES := 175.0        # doodle_speed_initial / doodle_speed_easy
const SPEED_HARD_FRAMES    :=  48.0        # doodle_speed_hard
# Normal mode speed floors (frames)
const SPEED_FLOOR_0_39  := 50.0
const SPEED_FLOOR_40_79 := 40.0
const SPEED_FLOOR_80_98 := 30.0
const SPEED_FLOOR_99    := 20.0

# ─── Mutable game state ───────────────────────────────────────────────────────

var mode : int = Mode.NORMAL
var score : int = 0
var lives : int = 6
var doodle_time : float = SPEED_INITIAL_FRAMES / FRAMES


func reset(p_mode: int) -> void:
	mode  = p_mode
	score = 0
	match mode:
		Mode.EASY:
			lives       = 10
			doodle_time = SPEED_INITIAL_FRAMES / FRAMES
		Mode.HARD:
			lives       = 3
			doodle_time = SPEED_HARD_FRAMES / FRAMES
		_:  # NORMAL
			lives       = 6
			doodle_time = SPEED_INITIAL_FRAMES / FRAMES


# Call once per round in NORMAL mode to accelerate the timer.
func advance_speed() -> void:
	if mode != Mode.NORMAL:
		return
	var decrement : float
	var floor_f   : float
	if score >= 99:
		decrement = 1.0; floor_f = SPEED_FLOOR_99
	elif score >= 80:
		decrement = 1.0; floor_f = SPEED_FLOOR_80_98
	elif score >= 40:
		decrement = 1.0; floor_f = SPEED_FLOOR_40_79
	else:
		decrement = 5.0; floor_f = SPEED_FLOOR_0_39
	doodle_time = max(doodle_time - decrement / FRAMES, floor_f / FRAMES)


func mode_name() -> String:
	match mode:
		Mode.EASY:   return "EASY"
		Mode.HARD:   return "HARD"
		_:           return "NORMAL"
