package com.zehfernando.display {
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Point;

	/**
	 * @author zeh
	 */
	public function drawPlane(graphics:Graphics, bitmap:BitmapData, p1:Point, p2:Point, p3:Point, p4:Point, scaleY:Number = 1, offsetY:Number = 0):void {
		var pc:Point = getIntersection(p1, p4, p2, p3); // Central point

		// If no intersection between two diagonals, doesn't draw anything
		if (!Boolean(pc)) return;

		// Lengths of first diagonal
		var ll1:Number = Point.distance(p1, pc);
		var ll2:Number = Point.distance(pc, p4);

		// Lengths of second diagonal
		var lr1:Number = Point.distance(p2, pc);
		var lr2:Number = Point.distance(pc, p3);

		// Ratio between diagonals
		var f:Number = (ll1 + ll2) / (lr1 + lr2);

		// Draws the triangle
		graphics.beginBitmapFill(bitmap, null, false, true);

		var ty:Number = (0 + offsetY) / scaleY;
		var by:Number = (1 + offsetY) / scaleY;

		graphics.drawTriangles(
			Vector.<Number>([p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y]),
			Vector.<int>([0,1,2, 1,3,2]),
			Vector.<Number>([0,ty,(1/ll2)*f, 1,ty,(1/lr2), 0,by,(1/lr1), 1,by,(1/ll1)*f]) // Magic
		);

	}
}

import flash.geom.Point;
function getIntersection(p1:Point, p2:Point, p3:Point, p4:Point): Point {
	// Returns a point containing the intersection between two lines
	// http://keith-hair.net/blog/2008/08/04/find-intersection-point-of-two-lines-in-as3/
	// http://www.gamedev.pastebin.com/f49a054c1

	var a1:Number = p2.y - p1.y;
	var b1:Number = p1.x - p2.x;
	var a2:Number = p4.y - p3.y;
	var b2:Number = p3.x - p4.x;

	var denom:Number = a1 * b2 - a2 * b1;
	if (denom == 0) return null;

	var c1:Number = p2.x * p1.y - p1.x * p2.y;
	var c2:Number = p4.x * p3.y - p3.x * p4.y;

	var p:Point = new Point((b1 * c2 - b2 * c1)/denom, (a2 * c1 - a1 * c2)/denom);

	if (Point.distance(p, p2) > Point.distance(p1, p2)) return null;
	if (Point.distance(p, p1) > Point.distance(p1, p2)) return null;
	if (Point.distance(p, p4) > Point.distance(p3, p4)) return null;
	if (Point.distance(p, p3) > Point.distance(p3, p4)) return null;

	return p;
}