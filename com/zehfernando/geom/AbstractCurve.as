package com.zehfernando.geom {
	import flash.geom.Point;
	/**
	 * @author zeh fernando
	 */
	public class AbstractCurve {

		// A base/abstract class for curves, useless by itself

		// Properties
		public var p1:Point;
		public var p2:Point;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AbstractCurve(__p1:Point, __p2:Point) {
			p1 = __p1;
			p2 = __p2;
		}

		// ================================================================================================================
		// PUBLIC functions -----------------------------------------------------------------------------------------------

		public function getPointOnCurve(__t:Number):Point {
			return Point.interpolate(p2, p1, __t);
		}

		public function decompose(__maximumErrorDistanceAllowed:Number = 1, __maximumSegments:int = 100):Vector.<Point> {
			// Decomposes a curve into line segments, given a maximum allowed error distance
			var points:Vector.<Point> = new Vector.<Point>();

			// Create items until the error drift is always smaller than the maximum allowed
			var i:int;
			var segments:int = 1; // Start with 1, which is quite possible if the curve is very straight
			var maxError:Number = NaN;
			var currentError:Number;
			var pCurve:Point;
			var pSegment:Point;
			while ((isNaN(maxError) || maxError > __maximumErrorDistanceAllowed) && segments < __maximumSegments) {
				maxError = 0;

				// Create all segments
				points.fixed = false;
				points.length = segments + 1;
				points.fixed = true;
				points[0] = p1;
				for (i = 1; i < segments; i++) {
					points[i] = getPointOnCurve(i/segments);
				}
				points[segments] = p2;

				// Verify error distance by checking the middle of every segment
				for (i = 0; i < points.length-1; i++) {
					pSegment = Point.interpolate(points[i], points[i+1], 0.5);
					pCurve = getPointOnCurve((i+0.5)/segments);
					currentError = Point.distance(pSegment, pCurve);
					if (currentError > maxError) {
						maxError = currentError;
						if (maxError > __maximumErrorDistanceAllowed) {
							// Off the maximum error distance already, no need to check further
							break;
						}
					}
				}

				segments++;
			}

			// Additional check to see if any of the other segments is removable
			// This is not strictly necessary but can happen for some curves
			for (i = 0; i < points.length-2; i++) {
				pSegment = Point.interpolate(points[i], points[i+2], 0.5);
				pCurve = getPointOnCurve((i+1)/segments);
				currentError = Point.distance(pSegment, pCurve);
				if (currentError < __maximumErrorDistanceAllowed) {
					// Can remove this point too
					points.splice(i+1, 1);
					i--;
				}
			}
 
			points.fixed = false;
			return points;
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get length():Number {
			return Point.distance(p1, p2);
		}
	}
}
