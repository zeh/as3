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
		private var _minimum:Number;
		private var _maximum:Number;
		private var _wrapValue:Boolean;						// If false, just clamps to max/min

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AttenuatedNumber(__divisor:Number = 2, __currentValue:Number = NaN, __minimum:Number = NaN, __maximum:Number = NaN, __wrapValue:Boolean = false) {
			_divisor = __divisor;
			_value = NaN;
			_minimum = __minimum;
			_maximum = __maximum;
			_wrapValue = __wrapValue;

			if (!isNaN(__currentValue)) push(__currentValue);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function checkBounds():void {
			if (!_wrapValue) {
				// Normal clamp
				if (!isNaN(_minimum) && _value < _minimum) {
					_value = _minimum;
				} else if (!isNaN(_maximum) && _value > _maximum) {
					_value = _maximum;
				}
			} else {
				// Wrap the value
				// Like MathUtils.rangeMod()
				if (!isNaN(_minimum) && !isNaN(_maximum) && (_value < _minimum || _value >= _maximum)) {
					_value = getWithinBoundsWrapping(_value, _minimum, _maximum);
				}
			}
		}

		private function getWithinBoundsWrapping(__value:Number, __min:Number, __max:Number):Number {
			var range:Number = __max - __min;
			__value = (__value - __min) % range;
			if (__value < 0) __value = range - (-__value % range);
			__value += __min;
			return __value;
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function push(__newValue:Number):void {
			if (isNaN(_value)) {
				_value = __newValue;
				checkBounds();
			} else {
				if (_wrapValue) {
					if (!isNaN(_minimum) && !isNaN(_maximum)) {
						// Proper wrap around (to the closest side)
						var range:Number = _maximum - _minimum;
						if (Math.abs(__newValue - _value) > range/2) {
							// Must flip the value
							if (__newValue > _value) {
								__newValue -= range;
							} else {
								__newValue += range;
							}
						}
						_value -= (_value - __newValue) / _divisor;
						checkBounds();
					} else {
						trace("AttenuatedNumber ERROR! Need minimum and maximum for proper wrapping! Currently: (" + _minimum + " => " + _maximum + ")");
					}
				} else {
					_value -= (_value - __newValue) / _divisor;
					checkBounds();
				}
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

		public function get minimum():Number {
			return _minimum;
		}

		public function set minimum(__value:Number):void {
			if (_minimum != __value) {
				_minimum = __value;
				checkBounds();
			}
		}

		public function get maximum():Number {
			return _maximum;
		}

		public function set maximum(__value:Number):void {
			if (_maximum != __value) {
				_maximum = __value;
				checkBounds();
			}
		}

		public function get wrapValue():Boolean {
			return _wrapValue;
		}

		public function set wrapValue(__value:Boolean):void {
			_wrapValue = __value;
		}
	}
}
