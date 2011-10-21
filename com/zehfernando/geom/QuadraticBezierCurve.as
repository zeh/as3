package com.zehfernando.geom {
	import flash.geom.Point;

	/**
	 * @author zeh
	 */
	public class QuadraticBezierCurve {

		// Properties
		public var p1:Point;
		public var p2:Point;
		public var cp:Point;

		// Temp
		public var nt:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function QuadraticBezierCurve(__p1:Point, __control:Point, __p2:Point) {
			p1 = __p1;
			p2 = __p2;
			cp = __control;
		}

		// ================================================================================================================
		// INSTANCE functions ---------------------------------------------------------------------------------------------


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function getPointOnCurve(__t:Number): Point {
			// http://en.wikipedia.org/wiki/B%C3%A9zier_curve
			nt = 2 * (1-__t);
			return new Point(p1.x + __t * (nt * (cp.x - p1.x) + __t * (p2.x - p1.x)), p1.y + __t * (nt * (cp.y - p1.y) + __t * (p2.y - p1.y)));
			//OLD//return new Point(2 * (1-__t) * (cp.x - p1.x) + 2 * __t * (p2.x - cp.x), 2 * (1-__t) * (cp.y - p1.y) + 2 * __t * (p2.y - cp.y));
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get length(): Number {
			return Point.distance(p1, p2);
		}
	}
}
