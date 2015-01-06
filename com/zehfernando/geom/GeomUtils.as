package com.zehfernando.geom {
	import flash.utils.Dictionary;
	import com.zehfernando.utils.console.error;
	import com.zehfernando.utils.console.log;

	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	/**
	 * @author zeh
	 */
	public class GeomUtils {

		// Constants
		public static var WINDING_CLOCKWISE:String = "clockwise";
		public static var WINDING_COUNTERCLOCKWISE:String = "counterclockwise";

		// Others
		public static const DEG2RAD:Number = Math.PI / 180; // Multiply by this number to convert degrees to radians
		public static const RAD2DEG:Number = 180 / Math.PI; // Multiply by this number to convert radians to degrees
		public static const HALF_PI:Number = Math.PI * 0.5;

		[Inline]
		public static function distanceSquared(__p1:Point, __p2:Point):Number {
			return sqr(__p1.x - __p2.x) + sqr(__p1.y - __p2.y);
		}

		[Inline]
		public static function sqr(__x:Number):Number {
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

		public static function getLineSegmentClosestPhaseToPoint(__point:Point, __p1:Point, __p2:Point):Number {
			// Find the position (0-1) where the closest point in the segment is in relation to __point
			var l2:Number = distanceSquared(__p1, __p2);
			if (l2 == 0) return 0;
			return ((__point.x - __p1.x) * (__p2.x - __p1.x) + (__point.y - __p1.y) * (__p2.y - __p1.y)) / l2;
		}

		public static function getPointIsToRightSideOfLine(__point:Point, __p1:Point, __p2:Point):Boolean {
//			log("=> " + GeomUtils.getPointIsToRightSideOfLine(new Point(100, 0), new Point(0, 0), new Point(100, 100))); // Should be: false
//			log("=> " + GeomUtils.getPointIsToRightSideOfLine(new Point(0, 100), new Point(0, 0), new Point(100, 100))); // Should be: true
//			log("=> " + GeomUtils.getPointIsToRightSideOfLine(new Point(100, 100), new Point(100, 0), new Point(0, 100))); // Should be: false
//			log("=> " + GeomUtils.getPointIsToRightSideOfLine(new Point(0, 0), new Point(100, 0), new Point(0, 100))); // Should be: true
//			log("=> " + GeomUtils.getPointIsToRightSideOfLine(new Point(0, 0), new Point(0, 100), new Point(100, 0))); // Should be: false
//			log("=> " + GeomUtils.getPointIsToRightSideOfLine(new Point(100, 100), new Point(0, 100), new Point(100, 0))); // Should be: true
//			log("=> " + GeomUtils.getPointIsToRightSideOfLine(new Point(0, 100), new Point(100, 100), new Point(0, 0))); // Should be: false
//			log("=> " + GeomUtils.getPointIsToRightSideOfLine(new Point(100, 0), new Point(100, 100), new Point(0, 0))); // Should be: true
//			log("=> " + GeomUtils.getPointIsToRightSideOfLine(new Point(-50, 0), new Point(0, 100), new Point(100, 100))); // Should be: false
//			log("=> " + GeomUtils.getPointIsToRightSideOfLine(new Point(200, 0), new Point(0, 100), new Point(100, 100))); // Should be: false
//			log("=> " + GeomUtils.getPointIsToRightSideOfLine(new Point(-50, 200), new Point(0, 100), new Point(100, 100))); // Should be: true
//			log("=> " + GeomUtils.getPointIsToRightSideOfLine(new Point(200, 200), new Point(0, 100), new Point(100, 100))); // Should be: true

			return ((__p2.x - __p1.x)*(__point.y - __p1.y) - (__p2.y - __p1.y)*(__point.x - __p1.x)) > 0;
		}

		public static function getLineSegmentDistanceToPoint(__point:Point, __p1:Point, __p2:Point):Number {
			// Find the minimum distance between this line segment and a point
			// http://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment

			var l2:Number = distanceSquared(__p1, __p2);
			if (l2 == 0) return Point.distance(__point, __p1);

			var t:Number = ((__point.x - __p1.x) * (__p2.x - __p1.x) + (__point.y - __p1.y) * (__p2.y - __p1.y)) / l2;
			if (t < 0) return Point.distance(__point, __p1);
			if (t > 1) return Point.distance(__point, __p2);
			return Math.sqrt(distanceSquared(__point, new Point(__p1.x + t * (__p2.x - __p1.x), __p1.y + t * (__p2.y - __p1.y))));
		}

		public static function simplifyPolygon(__points:Vector.<Point>, __isClosed:Boolean = false):Vector.<Point> {
			// Simplify the path by removing middle points in lines that have the same angle
//			var pl:int = points.length;
			// TODO: better understand closed loops?
			var newPoints:Vector.<Point> = new Vector.<Point>();
			newPoints.push(__points[0].clone());
			for (var i:int = 1; i < __points.length; i++) {
				if (!__points[i].equals(__points[i-1]) && Math.atan2(__points[i].y-__points[i-1].y, __points[i].x-__points[i-1].x) != Math.atan2(__points[(i+1) % __points.length].y-__points[i].y, __points[(i+1) % __points.length].x-__points[i].x)) {
					// Not the same point nor the same angle
					newPoints.push(__points[i].clone());
				}
			}
			if (!__isClosed) newPoints.push(__points[__points.length-1].clone());
			return newPoints;
		}

		public static function offsetPolygonEdges(__points:Vector.<Point>, __amount:Number):Vector.<Point> {
			// Offset all points of a polygon, creating a new set of points that defines all offset lines of the original polygon
			// The new list of points has 2x the original number of points

			var i:int;

			var p:Point, nextP:Point;
			var nextAngle:Number;
			var newPoints:Vector.<Point> = new Vector.<Point>(__points.length * 2, true);

			for (i = 0; i < __points.length; i++) {
				p = __points[i];
				nextP = __points[(i+1) % __points.length];
				nextAngle = Math.atan2(nextP.y - p.y, nextP.x - p.x);
				newPoints[i * 2] = Point.polar(__amount, nextAngle + HALF_PI).add(p);
				newPoints[i * 2 + 1] = Point.polar(__amount, nextAngle + HALF_PI).add(nextP);
			}

			return newPoints;
		}

		public static function filterPolygonsByWinding(__polygons:Vector.<Vector.<Point>>, __winding:String):Vector.<Vector.<Point>> {
			// Filter a polygon, by removing all the polygons that don't conform to a given winding
			var newPolys:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>();
			for (var i:int = 0; i < __polygons.length; i++) {
				if (GeomUtils.getPolygonWinding(__polygons[i]) == __winding) newPolys.push(__polygons[i]);
			}

			return newPolys;
		}

		private static function countPointsOld(__points:Vector.<Point>, __p:Point):int {
			// What does this function even do? It looks wrong. Ugh
			var c:int = 0;
			var pos:int;
			pos = 0;
			while (__points.indexOf(__p, pos) > -1) {
				pos = __points.indexOf(__p, pos) + 1;
				c++;
			}
			return pos;
		}

		private static function countPointsDunno(__points:Vector.<Point>, __p:Point):int {
			var c:int = 0;
			for (var i:int = 0; i < __points.length; i++) {
				if (__points[i].equals(__p)) c = i + 1;
			}
			return c;
		}

		private static function countPoints(__points:Vector.<Point>, __p:Point):int {
			var c:int = 0;
			for (var i:int = 0; i < __points.length; i++) {
				if (__points[i].equals(__p)) c++;
			}
			return c;
		}

		public static function decomposePolygon(__points:Vector.<Point>):Vector.<Vector.<Point>> {
			// Decomposes a polygon (as a series of points) into several different polygons, avoiding intersections and maintaining winding of each sub-area

			// Check all points for intersections
			var j:int;
			var p1:Point, p2:Point;
			var l:int = __points.length;
			var l1p1:int, l1p2:int;
			var l2p1:int, l2p2:int;
			var polygonsPoints:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>();
			var polygonsFirstPointIndex:Vector.<int> = new Vector.<int>();
			var polygonsNextPointIndex:Vector.<int> = new Vector.<int>();
			var polygonsNextPoint:Vector.<Point> = new Vector.<Point>();
			var polygonsLastIntersectionIndex:Vector.<int> = new Vector.<int>();

			var earliestIntersectionIndex:int;
			var earliestIntersectionLength:Number;
			var earliestIntersectionPoint:Point;
			var currentIntersectionLength:Number;
			var currentSegmentPoint:Point;
			var intersectionCacheSegments:Object = {};
			var cacheIndex:String;
			var intersectionsEvaluated:Vector.<Point> = new Vector.<Point>();
			//var tries:int = 10000;

			// Each polygon is a collection of points
			var polygonIndex:int = 0;
			polygonsPoints.push(new Vector.<Point>());
			polygonsFirstPointIndex.push(0);
			polygonsNextPointIndex.push(0);
			polygonsNextPoint.push(null);
			polygonsLastIntersectionIndex.push(-1);

			while (polygonIndex < polygonsPoints.length) { //  && tries-- > 0
				// Find the points of this segment
				l1p1 = polygonsNextPointIndex[polygonIndex];
				l1p2 = (l1p1 + 1) % l;

				if (polygonsNextPoint[polygonIndex] == null) {
					// Start checking this segment
					currentSegmentPoint = __points[l1p1];

//					log("  New segment: " + l1p1);
//					log("    +New point: " + l1p1 + " => " + currentSegmentPoint);

				} else {
					// Overridden: last point was an intersection, so restart checking from the intersection
					currentSegmentPoint = polygonsNextPoint[polygonIndex];
					polygonsNextPoint[polygonIndex] = null;

//					log("  New segment: " + l1p1 + "+");
//					log("    +New point: " + polygonsLastIntersectionIndex[polygonIndex] + "/" + l1p1 + " intersect (first) => " + currentSegmentPoint);
				}

				// Start checking this segment

				// Push the first point to the current polygon
				polygonsPoints[polygonIndex].push(currentSegmentPoint);

				// Check all subsequent lines for intersections
				earliestIntersectionIndex = -1;
				earliestIntersectionLength = 0;
				earliestIntersectionPoint = null;

				for (j = 2; j < l-1; j++) {
					l2p1 = (l1p1 + j) % l;
					l2p2 = (l1p1 + j + 1) % l;
					cacheIndex = l1p1 < l2p1 ? (l1p1 * 10000 + l2p1).toString() : (l2p1 * 10000 + l1p1).toString();
					if (polygonsLastIntersectionIndex[polygonIndex] < 0 || l2p1 != polygonsLastIntersectionIndex[polygonIndex]) {
//						log("      => checking " + l1p1+".."+l1p2+" => " + l2p1+".." + l2p2 + " (skipping " + polygonsLastIntersectionIndex[polygonIndex] + ")");
						// This check is made with two segments to ensure that the points are always the same (otherwise a segment of the original line would have an intersection point slighty different than the original intersection)
						p1 = getCachedIntersectionIndexed(__points[l1p1], __points[l1p2], __points[l2p1], __points[l2p2], intersectionCacheSegments, cacheIndex, true);
						//p1 = l1p1 < l2p1 ? GeomUtils.getLineIntersection(__points[l1p1].x, __points[l1p1].y, __points[l1p2].x, __points[l1p2].y, __points[l2p1].x, __points[l2p1].y, __points[l2p2].x, __points[l2p2].y, true) : GeomUtils.getLineIntersection(__points[l2p1].x, __points[l2p1].y, __points[l2p2].x, __points[l2p2].y, __points[l1p1].x, __points[l1p1].y, __points[l1p2].x, __points[l1p2].y, true);
						if (p1 != null) {
							p2 = __points[l1p1].equals(currentSegmentPoint) ? p1 : GeomUtils.getLineIntersection(currentSegmentPoint.x, currentSegmentPoint.y, __points[l1p2].x, __points[l1p2].y, __points[l2p1].x, __points[l2p1].y, __points[l2p2].x, __points[l2p2].y, true);
							if (p2 == null) p1 = null;
						}
						if (p1 != null && !p1.equals(currentSegmentPoint) && !p1.equals(__points[l1p1]) && !p1.equals(__points[l2p1]) && countPoints(polygonsPoints[polygonIndex], p1) < 4) {
							// There is an intersection
							currentIntersectionLength = GeomUtils.getPointDistance(currentSegmentPoint.x, currentSegmentPoint.y, p1.x, p1.y);
//							log("        => intersects at " + p1 + ", length = " + currentIntersectionLength);
							if (earliestIntersectionPoint == null || currentIntersectionLength < earliestIntersectionLength) {
								// The new intersection is earlier than the previous intersection, or there was no previous intersection
								earliestIntersectionIndex = l2p1;
								earliestIntersectionPoint = p1;
								earliestIntersectionLength = currentIntersectionLength;
							}
						}
					}
				}

				// Check if any intersection was found
				if (earliestIntersectionPoint != null) {
					// An intersection was found

//					log("  !Segment " + l1p1 + " intersects with segment " + earliestIntersectionIndex);

					if (earliestIntersectionPoint.equals(polygonsPoints[polygonIndex][0])) {
						// Intersection is the same as the first point, should close this polygon
						//log("  <Closing polygon at intersection, new index = " + (polygonIndex+1) + " / " + polygonsPoints.length);

						polygonIndex++;
					} else {
						// New intersection, turn and follow the new polygon

						polygonsNextPointIndex[polygonIndex] = earliestIntersectionIndex;
						polygonsNextPoint[polygonIndex] = earliestIntersectionPoint;
						polygonsLastIntersectionIndex[polygonIndex] = l1p1;

						// Create new starting point for testing later
						if (intersectionsEvaluated.indexOf(earliestIntersectionPoint) == -1) {
							//log("Creating new polygon for later, curr index = " + polygonIndex + " / " + (polygonsPoints.length+1));
							polygonsPoints.push(new Vector.<Point>());
							polygonsFirstPointIndex.push(-1);
							polygonsNextPointIndex.push(l1p1);
							polygonsNextPoint.push(earliestIntersectionPoint);
							polygonsLastIntersectionIndex.push(earliestIntersectionIndex);
							intersectionsEvaluated.push(earliestIntersectionPoint);

							if (earliestIntersectionPoint.equals(__points[l1p2])) {
								// The end point of the current segment intersects the other segment
								polygonsNextPointIndex[polygonsNextPointIndex.length - 1] = l1p2;
							}
						} else {
//							log("Skipping polygon creation");
							// Delete existing ones, if any
							for (j = polygonIndex + 1; j < polygonsNextPoint.length; j++) {
								if (polygonsNextPoint[j].equals(earliestIntersectionPoint)) {
									// This point was used, but was already marked to be used for a new polygon, so delete the new polygon
									polygonsPoints.splice(j, 1);
									polygonsFirstPointIndex.splice(j, 1);
									polygonsNextPointIndex.splice(j, 1);
									polygonsNextPoint.splice(j, 1);
									polygonsLastIntersectionIndex.splice(j, 1);
									j--;
								}
							}
						}
					}
				} else {
					// No intersection was found, so continue using this line
					polygonsNextPointIndex[polygonIndex] = (polygonsNextPointIndex[polygonIndex] + 1) % l;
					polygonsLastIntersectionIndex[polygonIndex] = -1;
					//log("  continuing @ " + polygonIndex + "...");

					if (polygonsFirstPointIndex[polygonIndex] > -1 && polygonsNextPointIndex[polygonIndex] == polygonsFirstPointIndex[polygonIndex]) {
						// Completed the polygon (normal point end)
						//log("  <Closing polygon at point, new index = " + (polygonIndex+1) + " / " + polygonsPoints.length);

						polygonIndex++;
					}
				}
			}

			return polygonsPoints;
		}

		private static function getCachedIntersection(__l1p1:Point, __l1p2:Point, __l2p1:Point, __l2p2:Point, __cache:Object, __asSegment:Boolean = true):Point {
			// This is the slowest part of all the algorithm
			var p1:String = __l1p1.x + "_" + __l1p1.y + "_" + __l1p2.x + "_" + __l1p2.y + "_";
			var p2:String = __l2p1.x + "_" + __l2p1.y + "_" + __l2p2.x + "_" + __l2p2.y + "_";
			var idx1:String = p1 + p2;
			var idx2:String = p2 + p1;
			if (__cache.hasOwnProperty(idx1)) return __cache[idx1];
			if (__cache.hasOwnProperty(idx2)) return __cache[idx2];
			__cache[idx1] = GeomUtils.getLineIntersection(__l1p1.x, __l1p1.y, __l1p2.x, __l1p2.y, __l2p1.x, __l2p1.y, __l2p2.x, __l2p2.y, __asSegment);
			return __cache[idx1];
		}

		private static function getCachedIntersectionIndexed(__l1p1:Point, __l1p2:Point, __l2p1:Point, __l2p2:Point, __cache:Object, __index:String, __asSegment:Boolean = true):Point {
			// This is the slowest part of all the algorithm
			if (!__cache.hasOwnProperty(__index)) __cache[__index] = GeomUtils.getLineIntersection(__l1p1.x, __l1p1.y, __l1p2.x, __l1p2.y, __l2p1.x, __l2p1.y, __l2p2.x, __l2p2.y, __asSegment);
			return __cache[__index];
		}

		public static function closePolygonEdgeGaps(__points:Vector.<Point>):Vector.<Point> {
			// Given a list of points that compose lines (pa, pb, pa, pb, ...) connect all end points with start points when the lines don't intersect, by extending them
			// TODO: allow milter limit and type of connection

			var newPoints:Vector.<Point> = new Vector.<Point>();
			var i:int = 0;
			var li1:int;
			var li2:int;
			var p:Point; // Intersection
			for (i = 0; i < __points.length; i += 2) {
				li1 = (i + 0) % __points.length;
				li2 = (i + 2) % __points.length;
				p = getLineIntersection(__points[li1].x, __points[li1].y, __points[li1+1].x, __points[li1+1].y, __points[li2].x, __points[li2].y, __points[li2+1].x, __points[li2+1].y, true);

//				log ("segment " + i + "/" + (__points.length/2) + " => intersects=" + (p != null));

				if (p != null) {
					// Lines intersect, so just connect the points
					newPoints.push(__points[li1+1]);
					newPoints.push(__points[li2]);
				} else {
					// No segment intersection
					if (GeomUtils.getPointDistance(__points[li1+1].x, __points[li1+1].y, __points[li2].x, __points[li2].y) < 0.0001) {
						// The points are the same, so just connect them
						newPoints.push(__points[li1+1]);
					} else {
						// Must close the gap by finding the intersection as a line
						p = getLineIntersection(__points[li1].x, __points[li1].y, __points[li1+1].x, __points[li1+1].y, __points[li2].x, __points[li2].y, __points[li2+1].x, __points[li2+1].y, false);

						if (p != null) {
							// Normal intersection
							newPoints.push(p);
						} else {
							// This only happens when lines are contained whithin each other, so treat like an intersection
							newPoints.push(__points[li1+1]);
							newPoints.push(__points[li2]);
						}
					}
				}
			}

			return newPoints;
		}

		public static function closePolygonEdgeGapsOld(__points:Vector.<Point>):Vector.<Point> {
			// Given a list of points that compose lines (pa, pb, pa, pb, ...) connect all end points with start points when the lines don't intersect, by extending them
			// TODO: allow milter limit and type of connection

			var newPoints:Vector.<Point> = new Vector.<Point>();
			var i:int = 0;
			var fi:int;
			var p:Point; // Intersection
			var skipNextStartPoint:Boolean = false;
			for (i = 0; i < __points.length; i+= 2) {
				fi = (i + 2) % __points.length;
				p = getLineIntersection(__points[i].x, __points[i].y, __points[i+1].x, __points[i+1].y, __points[fi].x, __points[fi].y, __points[fi+1].x, __points[fi+1].y, true);

				if (p != null) {
					// Lines intersect, so just push this line
					if (!skipNextStartPoint) newPoints.push(__points[i]);
					newPoints.push(__points[i+1]);

					skipNextStartPoint = false;
				} else {
					// No segment intersection, must close the gap by finding the intersection as a line
					p = getLineIntersection(__points[i].x, __points[i].y, __points[i+1].x, __points[i+1].y, __points[fi].x, __points[fi].y, __points[fi+1].x, __points[fi+1].y, false);

					if (p == null) {
						// Should never happen
						trace("No intersection between lines?!");
						return null;
					}

					newPoints.push(__points[i]);
					newPoints.push(p);

					skipNextStartPoint = true;
				}
			}

			if (skipNextStartPoint) {
				// Start point of first line should be skipped
				newPoints.splice(0, 1);
			}

			return newPoints;
		}

		public static function inflatePolygon(__points:Vector.<Point>, __amount:Number, __filterByWinding:Boolean):Vector.<Vector.<Point>> {
			// Inflates a closed polygon, as defined by a vector of points
			// The return value needs to be a list of a list because the polygon may be decomposed into two different polygons

			// TODO: milter limit
			// TODO: allow non-loop polygon

			var pts:Vector.<Point>;
			var ppts:Vector.<Vector.<Point>>;

//			var ti:int, timeSimplify:int, timeOffset:int, timeClose:int, timeDecompose:int, timeFilter:int;

			// Simplify points
//			ti = getTimer();
			pts = GeomUtils.simplifyPolygon(__points, true);
//			timeSimplify = getTimer() - ti;

			// Offset all segments as new segments
//			ti = getTimer();
			pts = GeomUtils.offsetPolygonEdges(pts, __amount);
//			timeOffset = getTimer() - ti;

			// Close gaps
//			ti = getTimer();
			pts = GeomUtils.closePolygonEdgeGaps(pts);
//			timeClose = getTimer() - ti;

			if (pts == null) {
				error("Points don't exist after closing gaps! was: " + __points);
				return new Vector.<Vector.<Point>>();
			}

			// Decompose polygons into several simple polygon
//			ti = getTimer();
			ppts = GeomUtils.decomposePolygon(pts);
//			timeDecompose = getTimer() - ti;

			if (__filterByWinding) {
				// Deflate polygons by removing different windings
//				ti = getTimer();
				ppts = GeomUtils.filterPolygonsByWinding(ppts, GeomUtils.getPolygonWinding(__points));
//				timeFilter = getTimer() - ti;
			}

//			log("Time spent: timeSimplify = " + timeSimplify + ", timeOffset = " + timeOffset + ", timeClose = " + timeClose + ", timeDecompose = " + timeDecompose + ", timeFilter = " + timeFilter);

			return ppts;
		}

		[Inline]
		public static function getPolygonWinding(__points:Vector.<Point>):String {
			var area:Number = getPolygonArea(__points);
			return area > 0 ? WINDING_COUNTERCLOCKWISE : WINDING_CLOCKWISE;
		}

		[Inline]
		public static function getPolygonArea(__points:Vector.<Point>):Number {
			// Calculate area of non-self-intersecting polygon, assumes it's closed
			var area:Number = 0;
			var j:Number;
			for (var i:int = 0; i < __points.length; i++) {
				j = (i + 1) % __points.length;
				area += __points[j].x * __points[i].y - __points[i].x * __points[j].y;
			}
			return area / 2;
		}

		public static function getLineIntersection(__ax1:Number, __ay1:Number, __ax2:Number, __ay2:Number, __bx1:Number, __by1:Number, __bx2:Number, __by2:Number, __asSegment:Boolean = true):Point {
			// Returns a point containing the intersection between two lines (segment or not)
			// http://keith-hair.net/blog/2008/08/04/find-intersection-point-of-two-lines-in-as3/
			// http://www.gamedev.pastebin.com/f49a054c1 (probably a faster implementation)

//			if (__asSegment) {
//				// Quickly identify segments that don't overlap
//				if (__ax1 < __bx1 && __ax2 < __bx1 && __ax1 < __bx2 && __ax2 < __bx2) return null;
//				if (__ax1 > __bx1 && __ax2 > __bx1 && __ax1 > __bx2 && __ax2 > __bx2) return null;
//				if (__ay1 < __by1 && __ay2 < __by1 && __ay1 < __by2 && __ay2 < __by2) return null;
//				if (__ay1 > __by1 && __ay2 > __by1 && __ay1 > __by2 && __ay2 > __by2) return null;
//			}

			var a1:Number = __ay2 - __ay1;
			var b1:Number = __ax1 - __ax2;
			var a2:Number = __by2 - __by1;
			var b2:Number = __bx1 - __bx2;

			var denom:Number = a1 * b2 - a2 * b1;
			if (denom == 0) return null;

			var c1:Number = __ax2 * __ay1 - __ax1 * __ay2;
			var c2:Number = __bx2 * __by1 - __bx1 * __by2;

			var px:Number = (b1 * c2 - b2 * c1)/denom;
			var py:Number = (a2 * c1 - a1 * c2)/denom;

			if (__asSegment) {
				var da:Number = getPointDistance(__ax1, __ay1, __ax2, __ay2);
				if (getPointDistance(px, py, __ax2, __ay2) > da) return null;
				if (getPointDistance(px, py, __ax1, __ay1) > da) return null;
				var db:Number = getPointDistance(__bx1, __by1, __bx2, __by2);
				if (getPointDistance(px, py, __bx2, __by2) > db) return null;
				if (getPointDistance(px, py, __bx1, __by1) > db) return null;
			}

			return new Point(px, py);
		}

		[Inline]
		public static function getPointDistance(__x1:Number, __y1:Number, __x2:Number, __y2:Number):Number {
			// Returns the distance between two points
			// Faster and using less memory than Point.distance
			var dx:Number = __x2 - __x1;
			var dy:Number = __y2 - __y1;
			return Math.sqrt(dx * dx + dy * dy);
		}

		public static function test_polygons(__graphics:Graphics):void {
			var ps:Vector.<Path> = new Vector.<Path>();
//			// Square
//			ps.push(Path.fromCoordinatesArray([0, 0, 100, 0, 100, 100, 0, 100]));
//			// Bad rectangle
//			ps.push(Path.fromCoordinatesArray([0, 0, 50, 0, 100, 0, 100, 100, 50, 100, 0, 100]));
//			// SVG triangle (from Anathematic SVG)
//			ps.push(Path.fromCoordinatesArray([0,43.5023, 25.1568,0, 50.2038,43.5023]));
//			ps.push(Path.fromCoordinatesArray([12.9063,49.2055, 38.0631,92.7077, 63.1102,49.2055]));
//			// SVG problematic rectangle (from Anathematic SVG)
//			ps.push(Path.fromCoordinatesArray([9, 16.7, 9.3, 16.7, 0, 16.7, 0, 8.8, 0, 0, 9.4, 0, 9, 0, 9, 8.3]));
//			ps[ps.length-1].scale(10, 5);
//			ps.push(Path.fromCoordinatesArray([141, 100, 0, 100, 71, 0]));
//			ps.push(Path.fromCoordinatesArray([100, 122, 0, 122, 50, 0]));
//			ps.push(Path.fromCoordinatesArray([100, 100, 0, 100, 50, 0]));
//			// SVG H that is not subdidiving (from Anathematic SVG)
//			ps.push(Path.fromCoordinatesArray([28.12299999999999,45.80969999999999,27.81840495626821,51.10010145772594,26.95074577259473,55.95616064139941,25.589211370262376,60.239531195335275,23.802990670553925,63.8118667638484,21.661272594752177,66.53482099125364,19.233246064139934,68.27004752186588,16.588099999999997,68.8792,13.94295393586009,68.27004752186593,11.51492740524779,66.53482099125364,9.373209329446041,63.81186676384837,7.586988629737618,60.239531195335275,6.225454227405265,55.95616064139941,5.357795043731784,51.10010145772594,5.053200000000004,45.80969999999999,5.053200000000004,45.04069999999999,0,45.04069999999999,0,90.63039999999998,4.833499999999987,90.63039999999998,5.496678240740721,85.15792175925924,6.770159259259259,80.28357407407407,8.568512499999997,76.18433749999997,10.806307407407388,73.03719259259259,13.398113425925914,71.0191199074074,16.258499999999998,70.30709999999999,19.11878287037038,71.01912685185184,21.710562962962968,73.0372148148148,23.948387499999995,76.18437499999999,25.746803703703705,80.2836185185185,27.020358796296307,85.15795648148148,27.683600000000013,90.63039999999998,33.396000000000015,90.63039999999998,33.396000000000015,45.04069999999999,28.12299999999999,45.04069999999999]));
//			ps[ps.length-1].translate(-8, -45);
//			ps[ps.length-1].scale(2, 2);
//			ps[ps.length-1].reverseWinding();
			// Simplified H with thin box corners
			//ps.push(Path.fromCoordinatesArray([0, 0, 5, 0, 5, 5, 48, 48, 52, 48, 95, 5, 95, 0, 100, 0, 100, 100, 95, 100, 95, 95, 52, 52, 48, 52, 5, 95, 5, 100, 0, 100]));
			// Simplified H with thicker box corners
			ps.push(Path.fromCoordinatesArray([0, 0, 20, 0, 20, 10, 48, 48, 52, 48, 80, 10, 80, 0, 100, 0, 100, 100, 80, 100, 80, 90, 52, 52, 48, 52, 20, 90, 20, 100, 0, 100]));
			//ps.push(Path.fromCoordinatesArray([0, 0, 48, 48, 52, 48, 100, 0, 100, 100, 52, 52, 48, 52, 0, 100]));
			// Simplified H
			//ps.push(Path.fromCoordinatesArray([0, 0, 48, 48, 100, 0, 100, 100, 48, 52, 0, 100]));
//			// Tiny rectangle
//			ps.push(Path.fromCoordinatesArray([20, 20, 100, 20, 100, 40, 20, 40]));
//			// C with flat line (From Anathematic SVG)
//			ps.push(Path.fromCoordinatesArray([15, 80, 30, 80, 0, 80, 0, 20, 30, 20, 15, 20]));
//			// 2-square
//			ps.push(Path.fromCoordinatesArray([0, 50, 100, 50, 100, 0, 50, 0, 50, 100, 0, 100]));
//			// 2-square with point that intersects edge
//			ps.push(Path.fromCoordinatesArray([0, 50, 50, 50, 100, 50, 100, 0, 50, 0, 50, 100, 0, 100]));
//			// 2-square with segment that intersects point
//			ps.push(Path.fromCoordinatesArray([0, 50, 100, 50, 100, 0, 50, 0, 50, 50, 50, 100, 0, 100]));
//			// 2-square with point that intersects point
//			ps.push(Path.fromCoordinatesArray([0, 50, 50, 50, 100, 50, 100, 0, 50, 0, 50, 50, 50, 100, 0, 100]));
//			// 3-square
//			ps.push(Path.fromCoordinatesArray([0, 50, 100, 50, 100, 100, 66, 100, 66, 0, 33, 0, 33, 100, 0, 100]));
//			// 3-square diagonal
//			ps.push(Path.fromCoordinatesArray([0, 66, 66, 66, 66, 0, 100, 0, 100, 33, 33, 33, 33, 100, 0, 100]));
//			// Star
//			ps.push(Path.fromCoordinatesArray([0, 30, 100, 30, 20, 100, 50, 0, 80, 100]));
//			// U different segments
//			ps.push(Path.fromCoordinatesArray([0, 0, 60, 0, 50, 40, 20, 40, 20, 90, 80, 90, 80, 55, 45, 55, 45, 10, 100, 10, 100, 100, 0, 100]));
//			// U same segment
//			ps.push(Path.fromCoordinatesArray([0, 0, 60, 0, 50, 60, 20, 60, 20, 90, 80, 90, 80, 55, 45, 55, 45, 10, 100, 10, 100, 100, 0, 100]));
//			// Crazy triangle
//			ps.push(Path.fromCoordinatesArray([10, 0, 90, 0, 30, 100, 0, 50, 100, 50, 70, 100]));
//			// Spiral
//			ps.push(Path.fromCoordinatesArray([0, 0, 100, 0, 100, 80, 20, 80, 20, 20, 80, 20, 80, 60, 40, 60, 40, 40, 60, 40, 60, 100, 0, 100]));
//			// Crazy
//			ps.push(Path.fromCoordinatesArray([0, 33, 33, 0, 33, 100, 0, 66, 100, 66, 66, 100, 66, 33]));
//			// Triangle
//			ps.push(Path.fromCoordinatesArray([0, 0, 0, 100, 100, 100]));
//			// Triangle with side
//			ps.push(Path.fromCoordinatesArray([0, 0, 0, 95, 5, 100, 100, 100]));
//			// Triangle with bigger side
//			ps.push(Path.fromCoordinatesArray([0, 0, 0, 90, 10, 100, 100, 100]));
//			// Triangle with flat part
//			ps.push(Path.fromCoordinatesArray([0, 0, 0, 100, 100, 100, 100, 80, 50, 80]));
//			// Triangle with flat part small
//			ps.push(Path.fromCoordinatesArray([0, 0, 0, 100, 100, 100, 100, 90, 50, 90]));
//			// Triangle flat
//			ps.push(Path.fromCoordinatesArray([0, 0, 0, 100, 100, 100, 90, 90, 90, 110, 100, 100, 70, 100]));
//			// M (simple)
//			ps.push(Path.fromCoordinatesArray([0, 0, 0, 100, 100, 100, 100, 0, 50, 80]));
//			// M (complex)
//			ps.push(Path.fromCoordinatesArray([0, 0, 0, 100, 100, 100, 100, 0, 50, 90]));

			var pw:Number = 110;
			var ph:Number = 110;
			var ots:Vector.<Point>, pts:Vector.<Point>;
			var ppts:Vector.<Vector.<Point>>;
			var winding:String;
			for (var i:int = 0; i < ps.length; i++) {
//				ppts = GeomUtils.inflatePolygon(ps[i].points, 10, true);
//				debug_drawPointses(__graphics, ppts, i * pw, ph * 1, 0xffff00, 0xff00ff, 0.5, 2);
//				continue;

				ps[i].simplify(true);

				ots = ps[i].points;

//				ppts = GeomUtils.decomposePolygon(ots);
//				debug_drawPointses(__graphics, ppts, i * pw, ph * 0, 0xffff00, 0xff00ff, 0.5, 2);

				// Original
				debug_drawPoints(__graphics, ots, 0 * pw, ph * i, 0xffffff, 1, 1);

				// Offset edges
				pts = GeomUtils.offsetPolygonEdges(ots, 5);
				debug_drawPoints(__graphics, pts, 1 * pw, ph * i, 0xffffff, 0.5, 1);

				// Close gaps
				pts = GeomUtils.closePolygonEdgeGaps(pts);
				debug_drawPoints(__graphics, pts, 2 * pw, ph * i, 0xffffff, 0.5, 1);

				// Decompose polygons
				ppts = GeomUtils.decomposePolygon(pts);
				debug_drawPointses(__graphics, ppts, 3 * pw, ph * i, 0xffff00, 0xff00ff, 0.5, 2);

				// Deflate polygons by removing winding
//				winding = GeomUtils.getPolygonWinding(ots);
//				ppts = GeomUtils.filterPolygonsByWinding(ppts, winding);
//				debug_drawPoints(__graphics, ots, i * pw, ph * 4, 0xffffff, 0.25, 1);
//				debug_drawPointses(__graphics, ppts, i * pw, ph * 4, 0xffffff, 0xffffff, 1, 1);
			}
		}

		private static function debug_drawPointses(__graphics:Graphics, __pointses:Vector.<Vector.<Point>>, __x:Number, __y:Number, __colorCW:uint, __colorCCW:uint, __alpha:Number, __strokeWidth:Number):void {
			log("Multi-poly " + __pointses.length + " polygons");
			for (var i:int = 0; i < __pointses.length; i++) {
				if (GeomUtils.getPolygonWinding(__pointses[i]) == GeomUtils.WINDING_CLOCKWISE) {
					debug_drawPoints(__graphics, __pointses[i], __x, __y, __colorCW, __alpha, __strokeWidth);
				} else {
					debug_drawPoints(__graphics, __pointses[i], __x, __y, __colorCCW, __alpha, __strokeWidth);
				}
			}
		}

		private static function debug_drawPoints(__graphics:Graphics, __points:Vector.<Point>, __x:Number, __y:Number, __color:uint, __alpha:Number, __strokeWidth:Number):void {
			const pScaleX:Number = 2;
			const pScaleY:Number = 4;

			log("  Polygon with " + __points.length + " points = " + __points);

			if (__points.length > 0) {
				var px:Number, py:Number;
				var i:Number;

				// Draws lines
				var started:Boolean = false;
				__graphics.lineStyle(__strokeWidth, __color, __alpha);
				for (i = 0; i < __points.length + 1; i++) {
					px = (__points[i % __points.length].x + __x + 20) * pScaleX;
					py = (__points[i % __points.length].y + __y + 20) * pScaleY;
					if (!started) {
						__graphics.moveTo(px, py);
						started = true;
					} else {
						__graphics.lineTo(px, py);
					}
				}

				// Draws corner points
				__graphics.lineStyle();
				for (i = 0; i < __points.length; i++) {
					px = (__points[i].x + __x + 20) * pScaleX;
					py = (__points[i].y + __y + 20) * pScaleY;
					__graphics.beginFill(__color, 0.5);
					__graphics.drawCircle(px, py, __strokeWidth * 3);
					__graphics.endFill();
				}
			}
		}
	}
}
