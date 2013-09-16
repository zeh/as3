package com.zehfernando.geom {
	import flash.geom.Point;

	/**
	 * @author zeh
	 */
	public class QuadraticBezierCurve extends AbstractCurve {

		// Properties
		public var cp:Point;

		// Temp
		public var nt:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function QuadraticBezierCurve(__p1:Point, __control:Point, __p2:Point) {
			super(__p1, __p2);
			cp = __control;
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function getPointOnCurve(__t:Number):Point {
			// http://en.wikipedia.org/wiki/B%C3%A9zier_curve
			nt = 2 * (1-__t);
			return new Point(
				p1.x + __t * (nt * (cp.x - p1.x) + __t * (p2.x - p1.x)),
				p1.y + __t * (nt * (cp.y - p1.y) + __t * (p2.y - p1.y))
			);
		}
	}
}
