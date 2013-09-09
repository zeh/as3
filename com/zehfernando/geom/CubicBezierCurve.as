package com.zehfernando.geom {
	import flash.geom.Point;

	/**
	 * @author zeh
	 */
	public class CubicBezierCurve {

		// Properties
		public var p1:Point;
		public var p2:Point;
		public var cp1:Point;
		public var cp2:Point;

		// Temp
		public var nt:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function CubicBezierCurve(__p1:Point, __control1:Point, __control2:Point, __p2:Point) {
			p1 = __p1;
			p2 = __p2;
			cp1 = __control1;
			cp2 = __control2;
		}

		// ================================================================================================================
		// INSTANCE functions ---------------------------------------------------------------------------------------------


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function getPointOnCurve(__t:Number): Point {
			// http://en.wikipedia.org/wiki/B%C3%A9zier_curve
			nt = 1-__t;
			return new Point(
				nt * nt * nt * p1.x + 3 * nt * nt * __t * cp1.x + 3 * nt * __t * __t * cp2.x + __t * __t * __t * p2.x,
				nt * nt * nt * p1.y + 3 * nt * nt * __t * cp1.y + 3 * nt * __t * __t * cp2.y + __t * __t * __t * p2.y
			);
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

//		public function get length():Number {
//			return Point.distance(p1, p2);
//		}
	}
}
