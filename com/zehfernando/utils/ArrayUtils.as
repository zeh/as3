package com.zehfernando.utils {
	/**
	 * @author zeh
	 */
	public class ArrayUtils {

		public static function shuffle(__array:Array): Array {
			// startIndex:int = 0, endIndex:int = 0):Array{
			// if(endIndex == 0) endIndex = this.length-1;
			var newArray:Array = [];
			while (__array.length > 0) {
				newArray.splice(Math.floor(Math.random() * (newArray.length+1)), 0, __array.pop());
			}

			return newArray;
		}

		public static function stringArrayToNumberArray(__array:Array):Array {
			var l:Array = [];
			if (Boolean(__array)) {
				for (var i:int = 0; i < __array.length; i++) l.push(parseFloat(__array[i]));
			}
			return l;
		}

	}
}
