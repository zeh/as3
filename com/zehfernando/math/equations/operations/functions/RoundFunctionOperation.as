package com.zehfernando.math.equations.operations.functions {

	/**
	 * @author zeh at zehfernando.com
	 */
	public class RoundFunctionOperation extends FunctionOperation {

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function RoundFunctionOperation() {
			super();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function operate(...__params):Number {
			return Math.round(__params[0]);
		}

		override public function toString():String {
			return "(round)";
		}
	}
}
