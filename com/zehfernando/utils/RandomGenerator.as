package com.zehfernando.utils {
	import flash.geom.Point;

	/**
	 * @author zeh fernando
	 */
	public class RandomGenerator {

		// Temp properties for speed
		private static var a:Number;
		private static var b:Number;
		private static var c:Number;
		private static var p:Number;

		private static const TWO_PI:Number = 2 * Math.PI;

		public static function getInCircle(__radius:Number):Point {
			// http://stackoverflow.com/questions/5837572/generate-a-random-point-within-a-circle-uniformly

			// Uniform generator (radius-angle would concentrate in middle)
			a = Math.random();
			b = Math.random();
			if (a > b) {
				c = b;
				b = a;
				a = c;
			}

			p = TWO_PI * a/b;

			return new Point(b * __radius * Math.cos(p), b * __radius * Math.sin(p));
		}

		public static function getInRange(__min:Number, __max:Number):Number {
			return __min + Math.random() * (__max-__min);
		}

		public static function getFromVector(__vector:Vector.<*>):Vector.<*> {
			return __vector[Math.floor(Math.random() * __vector.length)];
		}

		public static function getFromArray(__array:Array):* {
			return __array[Math.floor(Math.random() * __array.length)];
		}

		public static function getColor():uint {
			return (Math.random() * 0xffffff) & 0xffffff;
		}
	}
}
