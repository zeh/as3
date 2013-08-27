package com.zehfernando.utils {

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class MathUtils {

		public static const DEG2RAD:Number = 1/180 * Math.PI;
		public static const RAD2DEG:Number = 1/Math.PI * 180;

		private static var fp:Number;

		// Inlining: http://www.bytearray.org/?p=4789
		// Not working: returning a buffer underflow every time I try using it

		/**
		 * Clamps a number to a range, by restricting it to a minimum and maximum values: if the passed value is lower than the minimum value, it's replaced by the minimum; if it's higher than the maximum value, it's replaced by the maximum; if not, it's unchanged.
		 * @param __value	The value to be clamped.
		 * @param __min		Minimum value allowed.
		 * @param __max		Maximum value allowed.
		 * @return			The newly clamped value.
		 */
		public static function clamp(__value:Number, __min:Number = 0, __max:Number = 1):Number {
			return __value < __min ? __min : __value > __max ? __max : __value;
		}

		public static function clampAuto(__value:Number, __clamp1:Number = 0, __clamp2:Number = 1):Number {
			if (__clamp2 < __clamp1) {
				var v:Number = __clamp2;
				__clamp2 = __clamp1;
				__clamp1 = v;
			}
			return __value < __clamp1 ? __clamp1 : __value > __clamp2 ? __clamp2 : __value;
		}

		/**
		 * Maps a value from a range, determined by old minimum and maximum values, to a new range, determined by new minimum and maximum values. These minimum and maximum values are referential; the new value is not clamped by them.
		 * @param __value	The value to be re-mapped.
		 * @param __oldMin	The previous minimum value.
		 * @param __oldMax	The previous maximum value.
		 * @param __newMin	The new minimum value.
		 * @param __newMax	The new maximum value.
		 * @return			The new value, mapped to the new range.
		 */
		public static function map(__value:Number, __oldMin:Number, __oldMax:Number, __newMin:Number = 0, __newMax:Number = 1, __clamp:Boolean = false):Number {
			if (__oldMin == __oldMax) return __newMin;
			var p:Number = ((__value-__oldMin) / (__oldMax-__oldMin) * (__newMax-__newMin)) + __newMin;
			if (__clamp) p = __newMin < __newMax ? clamp(p, __newMin, __newMax) : clamp(p, __newMax, __newMin);
			return p;
		}

		public static function fastMap(__value:Number, __oldMin:Number, __oldMax:Number, __newMin:Number = 0, __newMax:Number = 1, __clamp:Boolean = false):Number {
			// Same as map, but without allocations
			if (__oldMin == __oldMax) return __newMin;
			fp = ((__value-__oldMin) / (__oldMax-__oldMin) * (__newMax-__newMin)) + __newMin;
			if (__clamp) fp = __newMin < __newMax ? clamp(fp, __newMin, __newMax) : clamp(fp, __newMax, __newMin);
			return fp;
		}

		/**
		 * Clamps a value to a range, by restricting it to a minimum and maximum values but folding the value to the range instead of simply resetting to the minimum and maximum. It works like a more powerful Modulo function.
		 * @param __value	The value to be clamped.
		 * @param __min		Minimum value allowed.
		 * @param __max		Maximum value allowed.
		 * @return			The newly clamped value.
		 * @example Some examples:
		 * <listing version="3.0">
		 * 	trace(MathUtils.roundClamp(14, 0, 10));
		 * 	// Result: 4
		 *
		 * 	trace(MathUtils.roundClamp(360, 0, 360));
		 * 	// Result: 0
		 *
		 * 	trace(MathUtils.roundClamp(360, -180, 180));
		 * 	// Result: 0
		 *
		 * 	trace(MathUtils.roundClamp(21, 0, 10));
		 * 	// Result: 1
		 *
		 * 	trace(MathUtils.roundClamp(-98, 0, 100));
		 * 	// Result: 2
		 * </listing>
		 */
		// Need a better name?
		public static function rangeMod(__value:Number, __min:Number, __pseudoMax:Number):Number {
			var range:Number = __pseudoMax - __min;
			__value = (__value - __min) % range;
			if (__value < 0) __value = range - (-__value % range);
			__value += __min;
			return __value;
		}
	}
}
