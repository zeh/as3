package com.zehfernando.geom {
	import com.zehfernando.utils.console.warn;

	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * @author zeh fernando
	 */
	public class Path {

		// Properties
		public var points:Vector.<Point>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Path() {
			points = new Vector.<Point>();
		}

		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------

		public static function fromPoints(__points:Vector.<Point>, __clone:Boolean = true, __optimize:Boolean = false):Path {
			var path:Path = new Path();
			if (__clone) {
				for (var i:int = 0; i < __points.length; i++) path.points.push(__points[i].clone());
			} else {
				path.points = __points;
			}
			if (__optimize) path.simplify();
			return path;
		}

		public static function fromCoordinates(__coordinates:Vector.<Number>, __optimize:Boolean = false):Path {
			var path:Path = new Path();
			for (var i:int = 0; i < __coordinates.length; i+=2) path.points.push(new Point(__coordinates[i], __coordinates[i+1]));
			if (__optimize) path.simplify();
			return path;
		}

		public static function fromCoordinatesArray(__coordinates:Array, __optimize:Boolean = false):Path {
			var path:Path = new Path();
			for (var i:int = 0; i < __coordinates.length; i+=2) path.points.push(new Point(__coordinates[i], __coordinates[i+1]));
			if (__optimize) path.simplify();
			return path;
		}


		// ================================================================================================================
		// INSTANCE functions ---------------------------------------------------------------------------------------------

//		public function intersectsRect(__rect:Rectangle):Boolean {
//			// Check if a rectangle intersects OR contains this line
//
//			if (__rect.containsPoint(p1) || __rect.containsPoint(p2)) return true;
//
//			if (intersectsLine(new Line(new Point(__rect.left, __rect.top),		new Point(__rect.right, __rect.top)))) return true;
//			if (intersectsLine(new Line(new Point(__rect.left, __rect.top),		new Point(__rect.left, __rect.bottom)))) return true;
//			if (intersectsLine(new Line(new Point(__rect.left, __rect.bottom),	new Point(__rect.right, __rect.bottom)))) return true;
//			if (intersectsLine(new Line(new Point(__rect.right, __rect.top),	new Point(__rect.right, __rect.bottom)))) return true;
//
//			return false;
//		}
//
//		public function intersectsLine(__line:Line):Boolean {
//			// Check whether two lines intersects each other
//			return Boolean(intersection(__line));
//		}
//
//		public function intersection(__line:Line): Point {
//			// Returns a point containing the intersection between two lines
//			// http://keith-hair.net/blog/2008/08/04/find-intersection-point-of-two-lines-in-as3/
//			// http://www.gamedev.pastebin.com/f49a054c1
//
//			var a1:Number = p2.y - p1.y;
//			var b1:Number = p1.x - p2.x;
//			var a2:Number = __line.p2.y - __line.p1.y;
//			var b2:Number = __line.p1.x - __line.p2.x;
//
//			var denom:Number = a1 * b2 - a2 * b1;
//			if (denom == 0) return null;
//
//			var c1:Number = p2.x * p1.y - p1.x * p2.y;
//			var c2:Number = __line.p2.x * __line.p1.y - __line.p1.x * __line.p2.y;
//
//			var p:Point = new Point((b1 * c2 - b2 * c1)/denom, (a2 * c1 - a1 * c2)/denom);
//
//			//if(as_seg){
//			if (Point.distance(p, p2) > Point.distance(p1, p2)) return null;
//			if (Point.distance(p, p1) > Point.distance(p1, p2)) return null;
//			if (Point.distance(p, __line.p2) > Point.distance(__line.p1, __line.p2)) return null;
//			if (Point.distance(p, __line.p1) > Point.distance(__line.p1, __line.p2)) return null;
//			//}
//
//			return p;
//
//		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function clone():Path {
			return Path.fromPoints(points, true);
		}

		public function simplify():void {
			// Simplify the path by removing middle points in lines that have the same angle
//			var pl:int = points.length;
			// TODO: better understood closed loops
			for (var i:int = 1; i < points.length-1; i++) {
				if (points[i].equals(points[i-1]) || Math.atan2(points[i].y-points[i-1].y, points[i].x-points[i-1].x) == Math.atan2(points[i+1].y-points[i].y, points[i+1].x-points[i].x)) {
					// Same point or same angle
					points.splice(i, 1);
					i--;
				}
			}
//			log("Path optimized; points before = " + pl + ", points after = " + points.length);
		}

		public function normalize():void {
			// Make sures all coordinates are from 0 to 1 by scaling the whole path back

			var bounds:Rectangle = getBounds();
			var i:int;

			// Apply mapped values
			for (i = 0; i < points.length; i++) {
				points[i].setTo((points[i].x - bounds.x) / bounds.width, (points[i].y - bounds.y) / bounds.height);
			}
		}

		public function getPositionSideRight(__point:Point):Boolean {
			// Return true if the position is believed to be on the 'right' side of the path (right side of a segment of the path)
			var i:int;
			var minDistance:Number = NaN;
			var distance:Number;
			var segmentPoint1:int;
			for (i = 0; i < points.length - 1; i++) {
				distance = GeomUtils.getLineSegmentDistanceToPoint(__point, points[i], points[i+1]);
				if (isNaN(minDistance) || distance < minDistance) {
					segmentPoint1 = i;
					minDistance = distance;
				}
			}
			return GeomUtils.getPointIsToRightSideOfLine(__point, points[segmentPoint1], points[segmentPoint1+1]);
		}

		public function getDistance(__point:Point):Number {
			// Get the closest distance to a point
			var i:int;
			var minDistance:Number = NaN;
			var distance:Number;
			for (i = 0; i < points.length - 1; i++) {
				distance = GeomUtils.getLineSegmentDistanceToPoint(__point, points[i], points[i+1]);
				if (isNaN(minDistance) || distance < minDistance) minDistance = distance;
			}
			return minDistance;
		}

		public function getClosestPositionNormalized(__point:Point):Number {
			// Get the point in the path (0-1) that is closest to another point
			return getClosestPosition(__point) / length;
		}

		public function getClosestPosition(__point:Point):Number {
			// Get the position in the path (0-length) that is closest to another point
			var i:int;
			var minDistance:Number = NaN;
			var distance:Number;
			var segmentPoint1:int;
			var segmentPointLength:Number;
			var totalLength:Number = 0;
			for (i = 0; i < points.length - 1; i++) {
				distance = GeomUtils.getLineSegmentDistanceToPoint(__point, points[i], points[i+1]);
				if (isNaN(minDistance) || distance < minDistance) {
					segmentPoint1 = i;
					segmentPointLength = totalLength;
					minDistance = distance;
				}
				totalLength += Point.distance(points[i], points[i+1]);
			}

			return segmentPointLength + GeomUtils.getLineSegmentClosestPhaseToPoint(__point, points[segmentPoint1], points[segmentPoint1+1]) * Point.distance(points[segmentPoint1], points[segmentPoint1+1]);
		}

		public function getClosestPoint(__point:Point):Point {
			// Get the point in the path that is closest to another point
			var i:int;
			var minDistance:Number = NaN;
			var distance:Number;
			var segmentPoint1:int;
			var segmentPointLength:Number;
			var totalLength:Number = 0;
			var closestPoint:Point = null;
			var p:Point;
			for (i = 0; i < points.length - 1; i++) {
				p = GeomUtils.getLineSegmentPointClosestToPoint(__point, points[i], points[i+1]);
				distance = GeomUtils.getLineSegmentDistanceToPoint(__point, points[i], points[i+1]);
				if (isNaN(minDistance) || distance < minDistance) {
					segmentPoint1 = i;
					segmentPointLength = totalLength;
					minDistance = distance;
					closestPoint = p;
				}
				totalLength += Point.distance(points[i], points[i+1]);
			}

			return closestPoint;
		}

		public function translate(__x:Number, __y:Number):void {
			// Moves all points by a certain amount
			var i:int;
			for (i = 0; i < points.length; i++) {
				points[i].setTo(points[i].x + __x, points[i].y + __y);
			}
		}

		public function scale(__scaleX:Number, __scaleY:Number, __pivot:Point = null):void {
			// Moves all points by a certain amount
			var i:int;
			if (__pivot == null) __pivot = new Point(0, 0);
			for (i = 0; i < points.length; i++) {
				points[i].setTo((points[i].x - __pivot.x) * __scaleX + __pivot.x, (points[i].y - __pivot.y) * __scaleY + __pivot.y);
			}
		}

		public function inflate(__amount:Number):Vector.<Path> {
			var paths:Vector.<Path> = Vector.<Path>();
			var pointses:Vector.<Vector.<Point>> = GeomUtils.inflatePolygon(points, __amount);
			for (var i:int = 0; i < points.length; i++) {
				paths.push(Path.fromPoints(pointses[i]));
			}
			return paths;
		}

		public function inflateOld(__amount:Number, __loop:Boolean = false):void {
			// Inflates the path by a given amount
			// If "loop", assumes it's a closed loop
			// TODO: milter limit

			const HALF_PI:Number = Math.PI * 0.5;
			var winding:String = getWinding();
			if (winding == GeomUtils.WINDING_CLOCKWISE) __amount *= -1; //? This should be the opposite
			var p:Point, prevP:Point, nextP:Point;
			var nextAngle:Number, prevAngle:Number;
			var newPoints:Vector.<Point> = new Vector.<Point>(points.length, false);

			var nextPA:Point, nextPB:Point;
			var prevPA:Point, prevPB:Point;
			var prevLine:Line, nextLine:Line;

			for (var i:int = 0; i < points.length; i++) {
				p = points[i];
				nextP = points[(i+1) % points.length];
				prevP = points[(i-1+points.length) % points.length];
				nextAngle = Math.atan2(nextP.y - p.y, nextP.x - p.x);
				prevAngle = Math.atan2(p.y - prevP.y, p.x - prevP.x);
				nextPA = Point.polar(__amount, nextAngle + HALF_PI).add(p);
				nextPB = Point.polar(__amount, nextAngle + HALF_PI).add(nextP);
				prevPA = Point.polar(__amount, prevAngle + HALF_PI).add(prevP);
				prevPB = Point.polar(__amount, prevAngle + HALF_PI).add(p);
				nextLine = new Line(nextPA, nextPB, true);
				prevLine = new Line(prevPA, prevPB, true);
				if (i == 0 && !__loop) {
					// Start
					newPoints[i] = nextPA;
				} else if (i == points.length - 1 && !__loop) {
					// End
					newPoints[i] = prevPB;
				} else {
					// Mid-point
					if (nextLine.intersectsLine(prevLine)) {
						// There's an intersection, use it
						newPoints[i] = nextLine.intersection(prevLine);
					} else {
						// No intersection, try to extend
						prevLine.setLength(prevLine.length + 1000, 0);
						nextLine.setLength(nextLine.length + 1000, 1);
						if (nextLine.intersectsLine(prevLine)) {
							// There's an intersection, use it
							newPoints[i] = nextLine.intersection(prevLine);
						} else {
							warn("Intersection too long " + nextPA, prevPB, i, "/", points.length);
							// Too long, must cut?
							// TODO: use milter limit
							newPoints[i] = new Point((nextPA.x + prevPB.x)/2, (nextPA.y + prevPB.y)/2);
						}
					}
				}
			}

			points = newPoints;
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get length():Number {
			var l:Number = 0;
			for (var i:int = 0; i < points.length-1; i++) {
				l += Point.distance(points[i], points[i+1]);
			}
			return l;
		}

		public function getPosition(__position:Number):Point {
			// Returns a point in this position in the path (0 to length)
			if (__position <= 0) return points[0].clone();

			var p:Number = 0;
			var l:Number;
			for (var i:int = 0; i < points.length-1; i++) {
				l = Point.distance(points[i], points[i+1]);
				if (p <= __position && p + l >= __position) {
					return Point.interpolate(points[i+1], points[i], (__position - p) / l);
				}
				p += l;
			}

			return points[points.length-1].clone();
		}

		public static function getSimilarity(__path0:Path, __path1:Path):Number {
			// Return the similarity between two paths, by measuring the distance of points at the same breakpoints in the path
			// simplify() and normalize() the paths before calling this function!
			// 0 = identical
			// Higher = more different
			var numSegs:int = 80; // Number of segments to check (more = more precise, less = faster)

			var errorDrift:Number = 0;

			var l0:Number = __path0.length;
			var l1:Number = __path1.length;

			for (var i:int = 0; i <= numSegs; i++) {
				errorDrift += Point.distance(__path0.getPosition((i/numSegs) * l0), __path1.getPosition((i/numSegs) * l1));
			}
			return errorDrift / numSegs;
		}

		public function toCoordinates():Vector.<Number> {
			var ps:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0; i < points.length; i++) {
				ps.push(points[i].x);
				ps.push(points[i].y);
			}
			return ps;
		}

		public function getWinding():String {
			return GeomUtils.getPolygonWinding(points);
		}

		public function getArea():Number {
			return GeomUtils.getPolygonArea(points);
		}

		public function getBounds():Rectangle {
			// Find the bounds of all the points in the path
			var i:int;
			var minX:Number;
			var maxX:Number;
			var minY:Number;
			var maxY:Number;

			// Read minimum and maximums
			for (i = 0; i < points.length; i++) {
				if (isNaN(minX) || points[i].x < minX) minX = points[i].x;
				if (isNaN(maxX) || points[i].x > maxX) maxX = points[i].x;
				if (isNaN(minY) || points[i].y < minY) minY = points[i].y;
				if (isNaN(maxY) || points[i].y > maxY) maxY = points[i].y;
			}

			return new Rectangle(minX, minY, maxX - minX, maxY - minY);
		}
	}
}
