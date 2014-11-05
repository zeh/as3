package com.zehfernando.math.equations.operations.modifiers {

	import com.zehfernando.math.equations.operations.modifiers.ModifierOperation;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class PositiveModifierOperation extends ModifierOperation {
		
		// Doesn't actually do anything

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function PositiveModifierOperation() {
			super();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function operate(...__params):Number {
			return -__params[0];
		}
		override public function toString():String {
			return "[+]";
		}

	}
}
