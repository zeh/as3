package com.zehfernando.math.equations.operations.modifiers {

	import com.zehfernando.math.equations.operations.BasicOperation;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class ModifierOperation extends BasicOperation {

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ModifierOperation() {
			super();

			_precedence = 1000;
			_numParameters = 1;
		}
		
		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function toString():String {
			return "[operation]";
		}
	}
}
