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

		var rect:Rectangle = __target.getBounds(__target);

		var rx:Number = rect.x * __target.scaleX;
		var ry:Number = rect.y * __target.scaleY;
		var rw:Number = rect.width * __target.scaleX;
		var rh:Number = rect.height * __target.scaleY;

		var bmp:BitmapData = new BitmapData(Math.ceil(rw + __safeMargin * 2), Math.ceil(rh + __safeMargin * 2), true, 0x00000000);

		var mtx:Matrix = new Matrix();
		mtx.translate(rx, ry);
		mtx.translate(__safeMargin, __safeMargin);

		bmp.draw(__target, mtx);

//		var bb:Bitmap = new Bitmap(bmp);
//		bb.x = 100;
//		bb.y = 100;
//		__target.parent.addChild(bb);

		// Remove contents
		var rr:Rectangle = bmp.getColorBoundsRect(0xff000000, 0x00000000, false);
		//trace ("-> ",rr.x, rr.y, bmp.width - rr.width - rr.x, bmp.height - rr.height - rr.y);

		bmp.dispose();
		bmp = null;

		var fRect:Rectangle = __target.getBounds(__targetCoordinateSpace);
		fRect.x += rr.x - __safeMargin;
		fRect.y += rr.y - __safeMargin;
		fRect.width = rr.width;
		fRect.height = rr.height;

		// TODO: scale must also be taken into consideration here!

		return fRect;
	}
}