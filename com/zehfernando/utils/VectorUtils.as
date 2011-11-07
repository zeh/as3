package com.zehfernando.utils {
	/**
	 * @author zeh at zehfernando.com
	 */
	public class VectorUtils {

		public static function stringVectorToArray(__vector:Vector.<String>):Array {
			var l:Array = [];
			for (var i:int = 0; i < __vector.length; i++) l.push(__vector[i]);
			return l;
		}

		public static function arrayToStringVector(__array:Array):Vector.<String> {
			var v:Vector.<String> = new Vector.<String>();
			for (var i:int = 0; i < __array.length; i++) v.push(__array[i]);
			return v;
		}

		public static function booleanVectorToArray(__vector:Vector.<Boolean>):Array {
			var l:Array = [];
			for (var i:int = 0; i < __vector.length; i++) l.push(__vector[i]);
			return l;
		}

		public static function arrayToBooleanVector(__array:Array):Vector.<Boolean> {
			var v:Vector.<Boolean> = new Vector.<Boolean>();
			for (var i:int = 0; i < __array.length; i++) v.push(__array[i]);
			return v;
		}

	}
}
