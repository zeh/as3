package com.zehfernando.input.binding {
	/**
	 * @author zeh fernando
	 */
	public class GamepadBinding implements IBinding {

		// Constants
		public static var GAMEPAD_INDEX_ANY:uint = 8165381;

		// Properties
		public var controlId:String;
		public var gamepadIndex:uint;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function GamepadBinding(__controlId:String, __gamepadIndex:uint) {
			super();

			controlId = __controlId;
			gamepadIndex = __gamepadIndex;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function matchesGamepadControl(__controlId:String, __gamepadIndex:uint):Boolean {
			return controlId == __controlId && (gamepadIndex == __gamepadIndex || gamepadIndex == GAMEPAD_INDEX_ANY);
		}

		public function matchesKeyboardKey(__keyCode:uint, __keyLocation:uint):Boolean {
			return false;
		}

		// TODO: add option to restrict to a given gamepad based on name? (e.g. OUYA)
	}
}