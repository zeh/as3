package com.zehfernando.input.binding {
	/**
	 * @author zeh fernando
	 */
	public class GamepadControls {

		// List of typical controls

		/* Directional pad LEFT
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const DPAD_LEFT:String = "BUTTON_21";

		/* Directional pad RIGHT
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const DPAD_RIGHT:String = "BUTTON_22";

		/* Directional pad UP
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const DPAD_UP:String = "BUTTON_19";

		/* Directional pad DOWN
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const DPAD_DOWN:String = "BUTTON_20";

		/* Directional pad LEFT
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: Playstation DS3</p>
		 */
		public static const DPAD_LEFT_SENSITIVE:String = "BUTTON_39"; // TODO: this wasn't working. Must test.

		/* Directional pad RIGHT
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: Playstation DS3</p>
		 */
		public static const DPAD_RIGHT_SENSITIVE:String = "BUTTON_37";

		/* Directional pad UP
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: Playstation DS3</p>
		 */
		public static const DPAD_UP_SENSITIVE:String = "BUTTON_36";

		/* Directional pad DOWN
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: Playstation DS3</p>
		 */
		public static const DPAD_DOWN_SENSITIVE:String = "BUTTON_38";

		/* Shoulder button, upper left (LEFT 1)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const L1:String = "BUTTON_102";

		/* Shoulder button, upper right (RIGHT 1)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const R1:String = "BUTTON_103";

		/* Shoulder button, lower left (LEFT 2)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const L2:String = "BUTTON_104";

		/* Should button, lower right (RIGHT 2)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const R2:String = "BUTTON_105";

		/* Left stick press (LEFT 3)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const L3:String = "BUTTON_106";

		/* Right stick press (RIGHT 3)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const R3:String = "BUTTON_107";

		/* Shoulder button, lower left (LEFT 2)
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const L2_SENSITIVE:String = "AXIS_17";

		/* Shoulder button, lower right (RIGHT 2)
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const R2_SENSITIVE:String = "AXIS_18";

		/* Left analog stick, horizontal (X) axis
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const STICK_LEFT_X:String = "AXIS_0";

		/* Left analog stick, vertical (Y) axis
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const STICK_LEFT_Y:String = "AXIS_1";

		/* Right analog stick, horizontal (X) axis
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const STICK_RIGHT_X:String = "AXIS_11";

		/* Right analog stick, vertical (Y) axis
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const STICK_RIGHT_Y:String = "AXIS_14";

		/* Action button, down (O in the OUYA, cross in the Playstation)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const BUTTON_ACTION_DOWN:String = "BUTTON_96";

		/* Action button, right (A in the OUYA, circle in the Playstation)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const BUTTON_ACTION_RIGHT:String = "BUTTON_97";

		/* Action button, up (Y in the OUYA, triangle in the Playstation)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const BUTTON_ACTION_UP:String = "BUTTON_99";

		/* Action button, left (U in the OUYA, square in the Playstation)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const BUTTON_ACTION_LEFT:String = "BUTTON_100";

		/* Start button
		 * <p>Style: digital</p>
		 * <p>Works in: Playstation DS3</p>
		 */
		public static const START:String = "BUTTON_108";

		// Unknowns

		/* Unknown control; declared by the GameInput API, but never used
		 * <p>Style: ?</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const BUTTON_UNKNOWN_BUTTON_32:String = "BUTTON_32";

		/* Unknown control; declared by the GameInput API, but never used
		 * <p>Style: ?</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const BUTTON_UNKNOWN_BUTTON_33:String = "BUTTON_33";

		/* Unknown control; declared by the GameInput API, but never used
		 * <p>Style: ?</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const BUTTON_UNKNOWN_BUTTON_34:String = "BUTTON_34";

		/* Unknown control; declared by the GameInput API, but never used
		 * <p>Style: ?</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const BUTTON_UNKNOWN_BUTTON_35:String = "BUTTON_35";

		// These were tested on PC only and may change

		/* Action button, down (green)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_BUTTON_ACTION_A:String = "BUTTON_4";

		/* Action button, right (red)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_BUTTON_ACTION_B:String = "BUTTON_5";

		/* Action button, up (yellow)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_BUTTON_ACTION_Y:String = "BUTTON_7";

		/* Action button, left (blue)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_BUTTON_ACTION_X:String = "BUTTON_6";

		/* Shoulder button, upper left (LEFT 1)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller, Playstation DS3</p>
		 */
		public static const XBOX_L1:String = "BUTTON_8";

		/* Shoulder button, upper right (RIGHT 1)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_R1:String = "BUTTON_9";

		/* Shoulder button, lower left (LEFT 2)
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_L2_SENSITIVE:String = "BUTTON_10";

		/* Shoulder button, lower right (RIGHT 2)
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_R2_SENSITIVE:String = "BUTTON_11";

		/* Left stick press (LEFT 3)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_L3:String = "BUTTON_14";

		/* Right stick press (RIGHT 3)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_R3:String = "BUTTON_15";

		/* Directional pad LEFT
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_DPAD_LEFT:String = "BUTTON_18";

		/* Directional pad RIGHT
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_DPAD_RIGHT:String = "BUTTON_19";

		/* Directional pad UP
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_DPAD_UP:String = "BUTTON_16";

		/* Directional pad DOWN
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_DPAD_DOWN:String = "BUTTON_17";

		/* BACK middle game controller button
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_BACK:String = "BUTTON_12";

		/* START middle game controller button
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller</p>
		 */
		public static const XBOX_START:String = "BUTTON_13";

	}
}
