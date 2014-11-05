package com.zehfernando.math.equations.operations.functions {

	import com.zehfernando.math.equations.operations.functions.FunctionOperation;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class SinFunctionOperation extends FunctionOperation {

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function SinFunctionOperation() {
			super();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function operate(...__params):Number {
			return Math.sin((__params[0] / 180) * Math.PI);
		}

		override public function toString():String {
			return "(sin)";
		}
	}
}
