package com.zehfernando.math.equations.operations.functions {

	import com.zehfernando.math.equations.operations.BasicOperation;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class FunctionOperation extends BasicOperation {
		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FunctionOperation() {
			super();

			_precedence = -1000;
			_numParameters = 1;
		}
		
		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function toString():String {
			return "(function)";
		}
	}
}
