package com.zehfernando.utils {

	// use atan2 instead?

	public function getAngle(x:Number, y:Number): Number {
		// Returns the angle (in radians) of a point
		// 0 = right side (3 o' clock)

		if (x == 0 && y == 0) return 0;
		var ang:Number = Math.atan(Math.abs(y) / Math.abs(x));
		/*
		ang /= Math.PI / 180; // dec to rad
		if (xDist < 0 && yDist >= 0) {
			ang = 180 - ang;
		} else if (xDist >= 0 && yDist < 0) {
			ang = 360 - ang;
		} else if (xDist < 0 && yDist < 0) {
			ang += 180;
		}
		*/

		if (x < 0 && y >= 0) {
			ang = Math.PI - ang;
		} else if (x >= 0 && y < 0) {
			ang = Math.PI*2 - ang;
		} else if (x < 0 && y < 0) {
			ang += Math.PI;
		}

		return (ang);
	}

}
