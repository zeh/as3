package com.zehfernando.math.equations.operations.operators {
	import com.zehfernando.math.equations.operations.BasicOperation;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class ParenthesisCloseOperation extends BasicOperation {

		// Special kind

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ParenthesisCloseOperation() {
			super();
			
			_precedence = -1;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function toString():String {
			return ")";
		}
	}
}
