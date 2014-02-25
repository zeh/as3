package com.zehfernando.geom {
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class Line {

		// Properties
		public var p1:Point;
		public var p2:Point;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Line(__p1:Point, __p2:Point, __clone:Boolean = false) {
			p1 = __clone ? __p1.clone() : __p1;
			p2 = __clone ? __p2.clone() : __p2;
		}


		// ================================================================================================================
		// INSTANCE functions ---------------------------------------------------------------------------------------------

		public function intersectsRect(__rect:Rectangle):Boolean {
			// Check if a rectangle intersects OR contains this line

			if (__rect.containsPoint(p1) || __rect.containsPoint(p2)) return true;

			if (intersectsLine(new Line(new Point(__rect.left, __rect.top),		new Point(__rect.right, __rect.top)))) return true;
			if (intersectsLine(new Line(new Point(__rect.left, __rect.top),		new Point(__rect.left, __rect.bottom)))) return true;
			if (intersectsLine(new Line(new Point(__rect.left, __rect.bottom),	new Point(__rect.right, __rect.bottom)))) return true;
			if (intersectsLine(new Line(new Point(__rect.right, __rect.top),	new Point(__rect.right, __rect.bottom)))) return true;

			return false;
		}

		public function intersectsLine(__line:Line):Boolean {
			// Check whether two lines intersects each other
			return Boolean(intersection(__line));
		}

		public function intersection(__line:Line): Point {
			// Returns a point containing the intersection between two lines
			// http://keith-hair.net/blog/2008/08/04/find-intersection-point-of-two-lines-in-as3/
			// http://www.gamedev.pastebin.com/f49a054c1

			var a1:Number = p2.y - p1.y;
			var b1:Number = p1.x - p2.x;
			var a2:Number = __line.p2.y - __line.p1.y;
			var b2:Number = __line.p1.x - __line.p2.x;

			var denom:Number = a1 * b2 - a2 * b1;
			if (denom == 0) return null;

			var c1:Number = p2.x * p1.y - p1.x * p2.y;
			var c2:Number = __line.p2.x * __line.p1.y - __line.p1.x * __line.p2.y;

			var p:Point = new Point((b1 * c2 - b2 * c1)/denom, (a2 * c1 - a1 * c2)/denom);

			//if(as_seg){
			if (Point.distance(p, p2) > Point.distance(p1, p2)) return null;
			if (Point.distance(p, p1) > Point.distance(p1, p2)) return null;
			if (Point.distance(p, __line.p2) > Point.distance(__line.p1, __line.p2)) return null;
			if (Point.distance(p, __line.p1) > Point.distance(__line.p1, __line.p2)) return null;
			//}

			return p;

		}

		public function setLength(__length:Number, __alignment:Number):void {
			// Sets the new length of the line; __alignment = 0 aligns to the starting point, __alignment == 1 to the end point
			if (isNaN(__length)) return;

			var l:Number = length;
			if (l == 0) return;
			var rest:Number = l - __length;
			var f0:Number = __alignment * rest;
			var f1:Number = (1-__alignment) * rest;
			var pp1:Point, pp2:Point;
			if (f0 == 0) {
				// Fast - start
				pp2 = Point.interpolate(p2, p1, (l-f1) / l);
				p2.setTo(pp2.x, pp2.y);
			} else if (f1 == 0) {
				// Fast - end
				pp1 = Point.interpolate(p2, p1, f0 / l);
				p1.setTo(pp1.x, pp1.y);
			} else {
				// Normal, middle
				pp1 = Point.interpolate(p2, p1, f0 / l);
				pp2 = Point.interpolate(p2, p1, (l-f1) / l);
				p1.setTo(pp1.x, pp1.y);
				p2.setTo(pp2.x, pp2.y);
			}
		}

		public function getDistance(__point:Point):Number {
			return GeomUtils.getLineSegmentDistanceToPoint(__point, p1, p2);
		}

		public function setAngle(__angle:Number):void {
			// Sets the angle, from the starting point
			// TODO: allow alignment of the new angle?
			p2 = p1.add(Point.polar(length, __angle));
		}

		public function getPoint(__position:Number):Point {
			// Find a point in the line (0-length)
			return Point.interpolate(p2, p1, __position / length);
		}

		public function getPointNormalized(__position:Number):Point {
			// Find a point in the line (0-1)
			return Point.interpolate(p2, p1, __position);
		}

		public function clone():Line {
			return new Line(p1.clone(), p2.clone());
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get length():Number {
			return Point.distance(p1, p2);
		}

		public function get angle():Number {
			return Math.atan2(p2.y - p1.y, p2.x - p1.x);
		}
	}
}
