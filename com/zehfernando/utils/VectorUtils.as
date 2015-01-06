package com.zehfernando.utils {
	/**
	 * @author zeh at zehfernando.com
	 */
	public class VectorUtils {

		// Array to vector

		public static function arrayToBooleanVector(__array:Array):Vector.<Boolean> {
			var v:Vector.<Boolean> = new Vector.<Boolean>();
			if (Boolean(__array)) {
				for (var i:int = 0; i < __array.length; i++) v.push(__array[i]);
			}
			return v;
		}

		public static function arrayToNumberVector(__array:Array):Vector.<Number> {
			var v:Vector.<Number> = new Vector.<Number>();
			if (Boolean(__array)) {
				for (var i:int = 0; i < __array.length; i++) v.push(__array[i]);
			}
			return v;
		}

		public static function arrayToStringVector(__array:Array):Vector.<String> {
			var v:Vector.<String> = new Vector.<String>();
			if (Boolean(__array)) {
				for (var i:int = 0; i < __array.length; i++) v.push(__array[i]);
			}
			return v;
		}

		// Vector to array

		public static function booleanVectorToArray(__vector:Vector.<Boolean>):Array {
			var l:Array = [];
			if (Boolean(__vector)) {
				for (var i:int = 0; i < __vector.length; i++) l.push(__vector[i]);
			}
			return l;
		}

		public static function numberVectorToArray(__vector:Vector.<Number>):Array {
			var l:Array = [];
			if (Boolean(__vector)) {
				for (var i:int = 0; i < __vector.length; i++) l.push(__vector[i]);
			}
			return l;
		}

		public static function stringVectorToArray(__vector:Vector.<String>):Array {
			var l:Array = [];
			if (Boolean(__vector)) {
				for (var i:int = 0; i < __vector.length; i++) l.push(__vector[i]);
			}
			return l;
		}

		// String to Vector

		public static function stringToStringVector(__string:String, __separator:String):Vector.<String> {
			var v:Vector.<String> = new Vector.<String>();
			if (Boolean(__string && __string.length > 0)) {
				var stringList:Array = __string.split(__separator);
				for (var i:int = 0; i < stringList.length; i++) v.push(stringList[i]);
			}
			return v;
		}

		// Other

		public static function getEquivalentItemFromNumberVector(__pos:Number, __max:int, __numbers:Vector.<Number>, __average:Boolean = true):Number {
			// Return an item from a number list mapped from the index of another list
			if (!__average) {
				// Don't allow average, just find a number
				return __numbers[Math.round(MathUtils.map(__pos, 0, __max, 0, __numbers.length - 1))];
			} else {
				// Allow average, find the two nearest items and use it
				var pos:Number = MathUtils.map(__pos, 0, __max, 0, __numbers.length - 1);
				var pos1:int = Math.floor(pos);
				var pos2:int = Math.min(pos1 + 1, __numbers.length - 1);
				return MathUtils.map(pos - pos1, 0, 1, __numbers[pos1], __numbers[pos2], true);
			}
		}

	}
}
