package com.zehfernando.data.types {

	import flash.events.EventDispatcher;
	/**
	 * @author zeh
	 */
	public class MedianNumber extends EventDispatcher {

		// Like AttenuatedNumber, but using a median

		// Properties
		protected var _maxLength:int;

		protected var _values:Vector.<Number>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function MedianNumber(__maxLength:int = 3, __startingValue:Number = NaN) {
			_maxLength = __maxLength;

			_values = new Vector.<Number>();

			if (!isNaN(__startingValue)) _values.push(__startingValue);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function checkLength(): void {
			// Check the length of the list
			if (_values.length > _maxLength) {
				_values.splice(0, _values.length - _maxLength);
			}
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function push(__value:Number): void {
			_values.push(__value);
			checkLength();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get value(): Number {
			if (_values.length == 0) return NaN;

			var tot:Number = 0;
			for (var i:int = 0; i < _values.length; i++) tot += _values[i];
			return tot / _values.length;
		}

		public function get maxLength(): int {
			return _maxLength;
		}
		public function set maxLength(__value:int): void {
			if (_maxLength != __value) {
				_maxLength = __value;
				checkLength();
			}
		}
	}
}
