package com.zehfernando.input.binding {
	/**
	 * @author zeh fernando
	 */
	public class GamepadSensitiveBinding extends GamepadBinding {

		// Properties
		public var minValue:Number;
		public var maxValue:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function GamepadSensitiveBinding(__controlId:String, __gamepadIndex:uint, __minValue:Number, __maxValue:Number) {
			super(__controlId, __gamepadIndex);

			minValue = __minValue;
			maxValue = __maxValue;
		}
	}
}