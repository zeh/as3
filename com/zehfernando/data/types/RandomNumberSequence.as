package com.zehfernando.data.types {
	/**
	 * @author zeh fernando
	 */
	public class RandomNumberSequence {
		// A sequence of random numbers

		// Properties
		private var numbers:Vector.<Number>;
		private var index:int;
		private var oldIndex:int;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function RandomNumberSequence(__min:Number = 0, __max:Number = 1, __items:int = 97) {
			index = 0;
			numbers = new Vector.<Number>();
			numbers.length = __items;
			numbers.fixed = true;
			for (var i:int = 0; i < numbers.length; i++) {
				numbers[i] = __min + Math.random() * (__max - __min);
			}
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function getNext():Number {
			oldIndex = index;
			index = (index + 1) % numbers.length;
			return numbers[oldIndex];
		}
	}
}
