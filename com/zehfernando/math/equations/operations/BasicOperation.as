package com.zehfernando.math.equations.operations {
	/**
	 * @author zeh at zehfernando.com
	 */
	public class BasicOperation {
		
		// Properties
		protected var _precedence:Number;
		protected var _numParameters:int;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BasicOperation() {
			_precedence = 0;
			_numParameters = 2;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------
		
		public function operate(...__params):Number {
			return __params[0];
		}
		
		public function operateAsModifier(__param:Number):Number {
			return __param;
		}
		
		public function get precedence():Number {
			return _precedence;
		}

		public function get numParameters():int {
			return _numParameters;
		}

		public function toString():String {
			return "";
		}
	}
}
