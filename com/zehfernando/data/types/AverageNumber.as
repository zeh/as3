package com.zehfernando.data.types {
	/**
	 * @author zeh
	 */
	public class AverageNumber {

		// Like AttenuatedNumber, but using an average

		// https://www.khanacademy.org/math/arithmetic/applying-math-reasoning-topic/reading_data/v/reading-bar-charts-3
		// Midrange: (higher + lower) / 2
		// Median: middle item (in case of an even number of items, the average of the middle two)
		// Average or mean: sumAllItems / numItems
		// Mode: most common item
		// Range: higher - lower

		// Properties
		private var _length:int;
		private var _maxLength:int;
		private var _position:int;
		private var _isDirty:Boolean;
		private var _value:Number;

		private var _values:Vector.<Number>;

		// Temp properties for speed/lesser memory consumption
		var i:int, tot:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AverageNumber(__maxLength:int = 3, __startingValue:Number = NaN) {
			_maxLength = __maxLength;
			_values = new Vector.<Number>();
			_values.length = _maxLength;
			_values.fixed = true;
			_position = 0;
			_isDirty = true;
			_value = NaN;
			_length = 0;

			if (!isNaN(__startingValue)) push(__startingValue);
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function push(__value:Number):void {
			_values[_position] = __value;
			_position = (_position+1) % _maxLength;
			if (_length < _maxLength) _length++;
			_isDirty = true;
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get value():Number {
			if (_isDirty) {
				// Calculates the median value
				if (_length == 0) {
					_value = NaN;
				} else {
					tot = 0;
					for (i = 0; i < _length; i++) {
						tot += _values[((_position - 1 - i) + _maxLength) % _maxLength];
					}
					_value = tot / _length;
				}
				_isDirty = false;
			}
			return _value;
		}

		public function get length():int {
			return _length;
		}

		public function set length(__value:int):void {
			if (__value < _length) {
				_length = __value;
				_isDirty = true;
			} else if (__value > _length) {
				trace("MedianNumber :: ERROR: Cannot set the length of a MedianNumber to a number higher than the current length");
			}
		}

		public function get maxLength():int {
			return _maxLength;
		}

		public function set maxLength(__value:int):void {
			if (_maxLength != __value) {
				if (__value < _length) {
					_length = __value;
					_isDirty = true;
				}

				_values.fixed = false;
				if (__value < _maxLength) {
					// Needs to cap existing values, move position
					var needsCapping:int = _maxLength - __value;
					var canCap:int = _maxLength - _position;
					if (canCap >= needsCapping) {
						// Normal cap
						_values.splice(_position, needsCapping);
					} else {
						// Needs to cap from the end, and start
						_values.splice(_position, canCap);
						_values.splice(0, needsCapping - canCap);
						_position -= needsCapping - canCap;
					}
					_position = _position % __value;
				} else {
					// Just increase the size of the existing array
					_values.length = __value;
				}
				_values.fixed = true;
				_maxLength = __value;
			}
		}
	}
}
