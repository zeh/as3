package com.zehfernando.math.equations.operations.functions {

	/**
	 * @author zeh at zehfernando.com
	 */
	public class CosFunctionOperation extends FunctionOperation {

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function CosFunctionOperation() {
			super();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function operate(...__params):Number {
			return Math.cos((__params[0] / 180) * Math.PI);
		}

		override public function toString():String {
			return "(cos)";
		}
	}
}
