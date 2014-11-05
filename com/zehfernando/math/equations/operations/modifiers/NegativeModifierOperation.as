package com.zehfernando.math.equations.operations.modifiers {

	import com.zehfernando.math.equations.operations.modifiers.ModifierOperation;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class NegativeModifierOperation extends ModifierOperation {

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function NegativeModifierOperation() {
			super();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function operate(...__params):Number {
			return -__params[0];
		}
		override public function toString():String {
			return "[-]";
		}

	}
}
