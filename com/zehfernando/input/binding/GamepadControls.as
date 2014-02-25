package com.zehfernando.input.binding {
	/**
	 * @author zeh fernando
	 */
	public class GamepadControls {

		// List of typical controls

		/* Horizontal axis of left stick
		 *
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: -1 (left) to 1 (right)</p>
		 */
		public static const STICK_LEFT_X:String = "stick_left_x";

		/* Vertical axis of left stick
		 *
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: -1 (up) to 1 (down)</p>
		 */
		public static const STICK_LEFT_Y:String = "stick_left_y";

		/* Pressing the left stick (also known as L3)
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const STICK_LEFT_PRESS:String = "stick_left_press";

		/* Horizontal axis of right stick
		 *
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: -1 (left) to 1 (right)</p>
		 */
		public static const STICK_RIGHT_X:String = "stick_right_x";

		/* Vertical axis of right stick
		 *
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: -1 (up) to 1 (down)</p>
		 */
		public static const STICK_RIGHT_Y:String = "stick_right_y";

		/* Pressing the right stick (also known as R3)
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const STICK_RIGHT_PRESS:String = "stick_right_press";

		/* Left shoulder bumper (also known as LB or L1)
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const LB:String = "left_button";

		/* Left shoulder trigger (also known as LT or L2)
		 *
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const LT:String = "left_trigger";

		/* Right shoulder bumper (also known as RB or R1)
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const RB:String = "right_button";

		/* Right shoulder trigger (also known as RT or R2)
		 *
		 * <p>Style: pressure-sensitive/analog</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const RT:String = "right_trigger";

		/* Directional pad up
		 *
		 * <p>Style: digital OR pressure-sensitive/analog</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3 [analog]; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const DPAD_UP:String = "dpad_up";

		/* Directional pad down
		 *
		 * <p>Style: digital OR pressure-sensitive/analog</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3 [analog]; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const DPAD_DOWN:String = "dpad_down";

		/* Directional pad left
		 *
		 * <p>Style: digital OR pressure-sensitive/analog</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3 [analog]; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const DPAD_LEFT:String = "dpad_left";

		/* Directional pad right
		 *
		 * <p>Style: digital OR pressure-sensitive/analog</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3 [analog]; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const DPAD_RIGHT:String = "dpad_right";

		/* Action button up (Y/yellow in the OUYA, Triangle/green in the Playstation, Y/yellow in the XBox 360)
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const ACTION_UP:String = "action_up";

		/* Action button down (O/green in the OUYA, Cross/blue in the Playstation, A/green in the XBox 360)
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const ACTION_DOWN:String = "action_down";

		/* Action button left (U/blue in the OUYA, Square/purple in the Playstation, X/blue in the XBox 360)
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const ACTION_LEFT:String = "action_left";

		/* Action button right (A/red in the OUYA, Circle/red in the Playstation, B/red in the XBox 360)
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const ACTION_RIGHT:String = "action_right";

		/* Back button (BACK in the XBox 360)
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA (XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const BACK:String = "meta_back";

		/* Select button
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: Windows (Generic Gamepad), OUYA (Playstation DS3)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const SELECT:String = "meta_select";

		/* Start button
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: OUYA (Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const START:String = "meta_start";

		/* Menu/home button (OUYA button in the OUYA controller, XBox Button in the XBox 360 controller, PS button in the Playstation controller)
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: Windows (Playstation DS4), OUYA (Native Controller; Playstation DS3; XBox 360 Controller)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const MENU:String = "meta_menu";

		/* Options button
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: Windows (Playstation DS4)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const OPTIONS:String = "meta_options";

		/* Trackpad press
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: Windows (Playstation DS4)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const TRACKPAD:String = "meta_trackpad";

		/* Share button
		 *
		 * <p>Style: digital</p>
		 * <p>Works in: Windows (Playstation DS4)</p>
		 * <p>Possible values: 0 (at rest) to 1 (pressed)</p>
		 */
		public static const SHARE:String = "meta_share";
	}
}
