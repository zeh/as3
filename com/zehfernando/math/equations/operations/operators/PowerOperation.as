package com.zehfernando.math.equations.operations.operators {
	import com.zehfernando.math.equations.operations.BasicOperation;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class PowerOperation extends BasicOperation {

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function PowerOperation() {
			super();
			
			_precedence = 4;
		}
		
		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function operate(...__params):Number {
			return Math.pow(__params[0], __params[1]);
		}

		override public function toString():String {
			return "^";
		}
	}
}
