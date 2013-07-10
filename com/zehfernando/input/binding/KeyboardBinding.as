package com.zehfernando.input.binding {

	/**
	 * @author zeh fernando
	 */
	public class KeyboardBinding implements IBinding {

		// Constants
		public static var KEY_LOCATION_ANY:uint = 8165381;
	
		// Properties
		public var keyCode:uint;
		public var keyLocation:uint;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------
	
		public function KeyboardBinding(__keyCode:uint, __keyLocation:uint) {
			super();

			keyCode = __keyCode;
			keyLocation = __keyLocation;
		}
		
		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function matchesKeyboardKey(__keyCode:uint, __keyLocation:uint):Boolean {
			return keyCode == __keyCode && (keyLocation == __keyLocation || keyLocation == KEY_LOCATION_ANY);
		}
	
		// TODO: add modifiers?
	}
}