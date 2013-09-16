package com.zehfernando.geom {
	import flash.geom.Point;

	/**
	 * @author zeh
	 */
	public class CubicBezierCurve extends AbstractCurve {

		// Properties
		public var cp1:Point;
		public var cp2:Point;

		// Temp
		public var nt:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function CubicBezierCurve(__p1:Point, __control1:Point, __control2:Point, __p2:Point) {
			super (__p1, __p2);
			cp1 = __control1;
			cp2 = __control2;
		}

		// ================================================================================================================
		// INSTANCE functions ---------------------------------------------------------------------------------------------


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function getPointOnCurve(__t:Number):Point {
			// http://en.wikipedia.org/wiki/B%C3%A9zier_curve
			nt = 1-__t;
			return new Point(
				nt * nt * nt * p1.x + 3 * nt * nt * __t * cp1.x + 3 * nt * __t * __t * cp2.x + __t * __t * __t * p2.x,
				nt * nt * nt * p1.y + 3 * nt * nt * __t * cp1.y + 3 * nt * __t * __t * cp2.y + __t * __t * __t * p2.y
			);
		}
	}
}
