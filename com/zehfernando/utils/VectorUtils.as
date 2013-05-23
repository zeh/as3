package com.zehfernando.utils {
	/**
	 * @author zeh at zehfernando.com
	 */
	public class VectorUtils {

		// Array to vector

		public static function arrayToStringVector(__array:Array):Vector.<String> {
			var v:Vector.<String> = new Vector.<String>();
			if (Boolean(__array)) {
				for (var i:int = 0; i < __array.length; i++) v.push(__array[i]);
			}
			return v;
		}

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

		// Vector to array

		public static function booleanVectorToArray(__vector:Vector.<Boolean>):Array {
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

		public static function numberVectorToArray(__vector:Vector.<Number>):Array {
			var l:Array = [];
			if (Boolean(__vector)) {
				for (var i:int = 0; i < __vector.length; i++) l.push(__vector[i]);
			}
			return l;
		}
	}
}
