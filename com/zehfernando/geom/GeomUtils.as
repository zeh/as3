package com.zehfernando.geom {

	import flash.geom.Rectangle;
	/**
	 * @author zeh
	 */
	public class GeomUtils {

		public static const DEG2RAD:Number = Math.PI / 180; // Multiply by this number to convert degrees to radians
		public static const RAD2DEG:Number = 180 / Math.PI; // Multiply by this number to convert radians to degrees

		public static function fitRectangle(__insideRect:Rectangle, __outsideRect:Rectangle, __fitAllInside:Boolean = true):Number {
			// Fits a rectangle inside another rectangle, and returns the scale the inner rectangle should have
			// This is good for fitting things in screens, like videos
			// __fitAllInside TRUE = Equivalent to StageScaleMode.SHOW_ALL
			// __fitAllInside FALSE = Equivalent to StageScaleMode.NO_BORDER

			// Screen/border dimensions
			var outsideRatio:Number = __outsideRect.width / __outsideRect.height;

			// Content/inside dimensions
			var insideRatio:Number = __insideRect.width / __insideRect.height;

			// This could be shorter
			var baseScale:Number;
			if (outsideRatio > insideRatio) {
				// Content is taller than screen
				if (__fitAllInside) {
					// Use height as base
					baseScale = __outsideRect.height / __insideRect.height;
				} else {
					// Use width as base
					baseScale = __outsideRect.width / __insideRect.width;
				}
			} else {
				// Content is wider than screen
				if (__fitAllInside) {
					// Use width as base
					baseScale = __outsideRect.width / __insideRect.width;
				} else {
					// Use height as base
					baseScale = __outsideRect.height / __insideRect.height;
				}
			}

			return baseScale;
		}
//		public static function fitRectangle(__insideRect:Rectangle, __outsideRect:Rectangle):Number {
//			// Fits a rectangle inside another rectangle, and returns the scale the inner rectangle should have
//			// This is good for fitting things in screens, like videos
//
//			// Screen/border dimensions
//			var outsideRatio:Number = __outsideRect.width / __outsideRect.height;
//
//			// Content/inside dimensions
//			var insideRatio:Number = __insideRect.width / __insideRect.height;
//
//			var baseScale:Number;
//			if (outsideRatio > insideRatio) {
//				// Content is taller than screen, use width as base
//				baseScale = __outsideRect.width / __insideRect.width;
//			} else {
//				// Content is wider than screen, use height as base
//				baseScale = __outsideRect.height / __insideRect.height;
//			}
//
//			return baseScale;
//		}
	}
}
