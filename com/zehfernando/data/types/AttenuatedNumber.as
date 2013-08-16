package com.zehfernando.data.types {
	/**
	 * @author zeh fernando
	 */
	public class AttenuatedNumber {

		// Takes number inputs and returns an attenuated value
		// Like AttenuatedNumber, but without enter_frame control

		// Properties
		private var _divisor:Number;
		private var _value:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AttenuatedNumber(__divisor:Number = 2, __currentValue:Number = NaN) {
			_divisor = __divisor;
			_value = NaN;

			if (!isNaN(__currentValue)) push(__currentValue);
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function push(__value:Number):void {
			if (isNaN(_value)) {
				_value = __value;
			} else {
				_value -= (_value - __value) / _divisor;
			}
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get value():Number {
			return _value;
		}

		public function set value(__value:Number):void {
			_value = __value;
		}

		public function get divisor():Number {
			return _divisor;
		}

		public function set divisor(__value:Number):void {
			_divisor = __value;
		}
	}
}
