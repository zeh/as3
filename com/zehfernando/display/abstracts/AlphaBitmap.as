package com.zehfernando.display.abstracts {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.geom.Matrix;
	import flash.geom.Point;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class AlphaBitmap extends ResizableSprite {

		// Instances
		protected var bitmapData:BitmapData;
		protected var bitmap:Bitmap;
		protected var alphaBitmapData:BitmapData;
		protected var alphaBitmap:Bitmap;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AlphaBitmap(__colorBitmap:BitmapData, __alphaBitmap:BitmapData = null, __canDisposeOf:Boolean = true) {
			super();

			var w:int = Math.max(__colorBitmap.width, Boolean(__alphaBitmap) ? __alphaBitmap.width : 0);
			var h:int = Math.max(__colorBitmap.height, Boolean(__alphaBitmap) ? __alphaBitmap.height : 0);

			var mtx:Matrix;

			// Create bitmap
			bitmapData = new BitmapData(w, h, true, 0x00000000);

			// Create RGB channels
			if (__colorBitmap.width == w && __colorBitmap.height == h) {
				// Same size, quick copy
				bitmapData.copyPixels(__colorBitmap,  __colorBitmap.rect, new Point(0, 0));
			} else {
				// Different size, resize befor copying
				mtx = new Matrix();
				mtx.scale(w / __colorBitmap.width, h / __colorBitmap.height);
				bitmapData.draw(__colorBitmap, mtx, null, null, null, true);
			}

			if (__canDisposeOf) __colorBitmap.dispose();

			if (Boolean(__alphaBitmap)) {
				// Create alpha channel
				if (__alphaBitmap.width == w && __alphaBitmap.height == h) {
					// Same size, quick copy
					bitmapData.copyChannel(__alphaBitmap,  __alphaBitmap.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
				} else {
					// Different size, resize befor copying -- also need to resize, ugh
					var alphaTemp:BitmapData = new BitmapData(w, h, true, 0x00000000);

					mtx = new Matrix();
					mtx.scale(w / __alphaBitmap.width, h / __alphaBitmap.height);
					alphaTemp.draw(__alphaBitmap, mtx, null, null, null, true);

					// Finally, quick copy
					bitmapData.copyChannel(alphaTemp,  alphaTemp.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);

					alphaTemp.dispose();
					alphaTemp = null;
				}

				if (__canDisposeOf) __alphaBitmap.dispose();
			}

			// Attach
			bitmap = new Bitmap(bitmapData);
			bitmap.smoothing = true;
			addChild(bitmap);
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function fromBitmaps(__colorBitmap:Bitmap, __alphaBitmap:Bitmap = null, __canDisposeOf:Boolean = true): AlphaBitmap {
			var alphaBitmap:AlphaBitmap = new AlphaBitmap(__colorBitmap.bitmapData, Boolean(__alphaBitmap) ? __alphaBitmap.bitmapData : null, __canDisposeOf);

			if (__canDisposeOf) {
				__colorBitmap.bitmapData = null;
				if (Boolean(__alphaBitmap)) __alphaBitmap.bitmapData = null;
			}

			return alphaBitmap;
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth():void {
			bitmap.width = _width;
		}

		override protected function redrawHeight():void {
			bitmap.height = _height;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function dispose():void {
			bitmapData.dispose();
			bitmap.bitmapData = null;
			removeChild(bitmap);
			bitmap = null;
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get smoothing():Boolean {
			return bitmap.smoothing;
		}
		public function set smoothing(__value:Boolean):void {
			bitmap.smoothing = __value;
		}
	}
}
