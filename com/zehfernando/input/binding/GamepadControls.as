package com.zehfernando.input.binding {
	/**
	 * @author zeh fernando
	 */
	public class GamepadControls {

		// List of typical controls

		/* Directional pad LEFT
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA)</p>
		 */
		public static const DPAD_LEFT:String = "BUTTON_21";

		/* Directional pad RIGHT
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA)</p>
		 */
		public static const DPAD_RIGHT:String = "BUTTON_22";

		/* Directional pad UP
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA)</p>
		 */
		public static const DPAD_UP:String = "BUTTON_19";

		/* Directional pad DOWN
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA)</p>
		 */
		public static const DPAD_DOWN:String = "BUTTON_20";

		/* Directional pad LEFT
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: Playstation DS3 (OUYA)</p>
		 */
		public static const DPAD_LEFT_SENSITIVE:String = "BUTTON_39"; // TODO: this wasn't working. Must test.

		/* Directional pad RIGHT
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: Playstation DS3 (OUYA)</p>
		 */
		public static const DPAD_RIGHT_SENSITIVE:String = "BUTTON_37";

		/* Directional pad UP
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: Playstation DS3 (OUYA)</p>
		 */
		public static const DPAD_UP_SENSITIVE:String = "BUTTON_36";

		/* Directional pad DOWN
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: Playstation DS3 (OUYA)</p>
		 */
		public static const DPAD_DOWN_SENSITIVE:String = "BUTTON_38";

		/* Shoulder button, upper left (LEFT 1)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA)</p>
		 */
		public static const L1:String = "BUTTON_102";

		/* Shoulder button, upper right (RIGHT 1)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA)</p>
		 */
		public static const R1:String = "BUTTON_103";

		/* Shoulder button, lower left (LEFT 2)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA)</p>
		 * <p>Note: this doesn't work on the XBox 360 Controller (OUYA). Use L2_SENSITIVE instead.</p>
		 */
		public static const L2:String = "BUTTON_104";

		/* Should button, lower right (RIGHT 2)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA)</p>
		 * <p>Note: this doesn't work on the XBox 360 Controller (OUYA). Use R2_SENSITIVE instead.</p>
		 */
		public static const R2:String = "BUTTON_105";

		/* Left stick press (LEFT 3)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA)</p>
		 */
		public static const L3:String = "BUTTON_106";

		/* Right stick press (RIGHT 3)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA)</p>
		 */
		public static const R3:String = "BUTTON_107";

		/* Shoulder button, lower left (LEFT 2)
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA)</p>
		 */
		public static const L2_SENSITIVE:String = "AXIS_17";

		/* Shoulder button, lower right (RIGHT 2)
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA)</p>
		 */
		public static const R2_SENSITIVE:String = "AXIS_18";

		/* Left analog stick, horizontal (X) axis. The value received is for a left-to-right position.
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA), XBox 360 Controller (Windows)</p>
		 */
		public static const STICK_LEFT_X:String = "AXIS_0";

		/* Left analog stick, vertical (Y) axis. The value received is for a up-to-down position.
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA), XBox 360 Controller (Windows)</p>
		 * <p>Note: on Windows, when using the XBox 360 controller, the orientation is reversed: the value position is down-to-up.</p>
		 */
		public static const STICK_LEFT_Y:String = "AXIS_1";

		/* Right analog stick, horizontal (X) axis. The value received is for a left-to-right position.
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA), XBox 360 Controller (Windows)</p>
		 */
		public static const STICK_RIGHT_X:String = "AXIS_11";

		/* Right analog stick, vertical (Y) axis. The value received is for a up-to-down position.
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA), XBox 360 Controller (Windows)</p>
		 * <p>Note: on Windows, when using the XBox 360 controller, the orientation is reversed: the value position is down-to-up.</p>
		 */
		public static const STICK_RIGHT_Y:String = "AXIS_14";

		/* Action button, down (O/green in the OUYA, Cross/blue in the Playstation, A/green in the XBox 360)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA), XBox 360 Controller (Windows)</p>
		 */
		public static const BUTTON_ACTION_DOWN:String = "BUTTON_96";

		/* Action button, right (A/red in the OUYA, Circle/red in the Playstation, B/red in the XBox 360)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA)</p>
		 */
		public static const BUTTON_ACTION_RIGHT:String = "BUTTON_97";

		/* Action button, up (Y/yellow in the OUYA, Triangle/green in the Playstation, Y/yellow in the XBox 360)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA)</p>
		 */
		public static const BUTTON_ACTION_UP:String = "BUTTON_100";

		/* Action button, left (U/blue in the OUYA, Square/purple in the Playstation, X/blue in the XBox 360)
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA Controller (OUYA), Playstation DS3 (OUYA), XBox 360 Controller (OUYA)</p>
		 */
		public static const BUTTON_ACTION_LEFT:String = "BUTTON_99";

		/* Start button
		 * <p>Style: digital</p>
		 * <p>Works in: Playstation DS3 (OUYA)</p>
		 * <p>Note: this is also present on the XBox 360 controller (OUYA), but never used.</p>
		 */
		public static const START:String = "BUTTON_108";


		// Unknowns: listed in some device but never used

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


		// PC-only. Move to a separate class?

		/* Action button, down (A/green)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_BUTTON_ACTION_A:String = "BUTTON_4";

		/* Action button, right (B/red)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_BUTTON_ACTION_B:String = "BUTTON_5";

		/* Action button, up (Y/yellow)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_BUTTON_ACTION_Y:String = "BUTTON_7";

		/* Action button, left (X/blue)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_BUTTON_ACTION_X:String = "BUTTON_6";

		/* Shoulder button, upper left (LEFT 1)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_L1:String = "BUTTON_8";

		/* Shoulder button, upper right (RIGHT 1)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_R1:String = "BUTTON_9";

		/* Shoulder button, lower left (LEFT 2)
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_L2_SENSITIVE:String = "BUTTON_10";

		/* Shoulder button, lower right (RIGHT 2)
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_R2_SENSITIVE:String = "BUTTON_11";

		/* Left stick press (LEFT 3)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_L3:String = "BUTTON_14";

		/* Right stick press (RIGHT 3)
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_R3:String = "BUTTON_15";

		/* Directional pad LEFT
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_DPAD_LEFT:String = "BUTTON_18";

		/* Directional pad RIGHT
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_DPAD_RIGHT:String = "BUTTON_19";

		/* Directional pad UP
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_DPAD_UP:String = "BUTTON_16";

		/* Directional pad DOWN
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_DPAD_DOWN:String = "BUTTON_17";

		/* BACK middle game controller button
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_BACK:String = "BUTTON_12";

		/* START middle game controller button
		 * <p>Style: digital</p>
		 * <p>Works in: XBox 360 Controller (Windows)</p>
		 */
		public static const XBOX_START:String = "BUTTON_13";

	}
}
