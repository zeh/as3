package com.zehfernando.geom {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * @author zeh
	 */
	public class GeomUtils {

		public static const DEG2RAD:Number = Math.PI / 180; // Multiply by this number to convert degrees to radians
		public static const RAD2DEG:Number = 180 / Math.PI; // Multiply by this number to convert radians to degrees

		[Inline]
		public final static function distanceSquared(__p1:Point, __p2:Point):Number {
			return sqr(__p1.x - __p2.x) + sqr(__p1.y - __p2.y);
		}

		[Inline]
		public final static function sqr(__x:Number):Number {
			return __x * __x;
		}

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

		public static function getLineSegmentDistanceToPoint(__point:Point, __p1:Point, __p2:Point):Number {
			// Find the minimum distance between this line and a point
			// http://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment

			var l2:Number = distanceSquared(__p1, __p2);
			if (l2 == 0) return Point.distance(__point, __p1);

			var t:Number = ((__point.x - __p1.x) * (__p2.x - __p1.x) + (__point.y - __p1.y) * (__p2.y - __p1.y)) / l2;
			if (t < 0) return Point.distance(__point, __p1);
			if (t > 1) return Point.distance(__point, __p2);
			return Math.sqrt(distanceSquared(__point, new Point(__p1.x + t * (__p2.x - __p1.x), __p1.y + t * (__p2.y - __p1.y))));
		}
	}
}
