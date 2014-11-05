package com.zehfernando.math.equations.operations.operators {
	import com.zehfernando.math.equations.operations.BasicOperation;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class AddOperation extends BasicOperation {

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AddOperation() {
			super();
			
			_precedence = 2;
		}
		
		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function operate(...__params):Number {
			return __params[0] + __params[1];
		}

		override public function toString():String {
			return "+";
		}
	}
}
