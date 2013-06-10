package com.zehfernando.display.utils {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	/**
	 * @author zeh
	 */
	public function getRealBounds(__target:DisplayObject, __targetCoordinateSpace:DisplayObject, __safeMargin:Number = 20): Rectangle {
		// This is like DisplayObject.getBounds(), but correct
		// Safe margin does not expand the size, but should be as big as necessary - some items (like bottom of some fonts) fall outside the getBounds margin

		var rect:Rectangle = __target.getBounds(__target);

		var rx:Number = rect.x;
		var ry:Number = rect.y;
		var rw:Number = rect.width * __target.scaleX;
		var rh:Number = rect.height * __target.scaleY;

		if (rw <= 0) rw = 1;
		if (rh <= 0) rh = 1;

		var bmp:BitmapData = new BitmapData(Math.ceil(rw + __safeMargin * 2 * __target.scaleX), Math.ceil(rh + __safeMargin * 2 * __target.scaleY), true, 0x00000000);

		var mtx:Matrix = new Matrix();
		mtx.scale(__target.scaleX, __target.scaleY);
		mtx.translate(__safeMargin * __target.scaleX, __safeMargin * __target.scaleY);
		mtx.translate(-rx * __target.scaleX, -ry * __target.scaleY);
		bmp.draw(__target, mtx);

		// Remove contents
		var rr:Rectangle = bmp.getColorBoundsRect(0xff000000, 0x00000000, false);

		bmp.dispose();
		bmp = null;

		var fRect:Rectangle = __target.getBounds(__targetCoordinateSpace);
		fRect.x += rr.x - __safeMargin * __target.scaleX;
		fRect.y += rr.y - __safeMargin * __target.scaleY;
		fRect.width = rr.width;
		fRect.height = rr.height;

		return fRect;
	}
}