package com.zehfernando.data.types {
	/**
	 * @author zeh fernando
	 */
	public class RandomBooleanSequence {
		// A sequence of booleans numbers

		// Properties
		private var booleans:Vector.<Boolean>;
		private var index:int;
		private var oldIndex:int;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function RandomBooleanSequence(__items:int = 97) {
			index = 0;
			booleans = new Vector.<Boolean>();
			booleans.length = __items;
			booleans.fixed = true;
			for (var i:int = 0; i < booleans.length; i++) {
				booleans[i] = Math.random() < 0.5;
			}
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function getNext():Boolean {
			oldIndex = index;
			index = (index + 1) % booleans.length;
			return booleans[oldIndex];
		}
	}
}
