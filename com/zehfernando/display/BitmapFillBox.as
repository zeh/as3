package com.zehfernando.display {

	import com.zehfernando.display.abstracts.ResizableSprite;
	import com.zehfernando.utils.RenderUtils;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * @author zeh
	 */
	public class BitmapFillBox extends ResizableSprite {

		// Creates a bitmap with a tiled pattern

		// Constants
		public static const ALIGN_HORIZONTAL_LEFT:String = "left";
		public static const ALIGN_HORIZONTAL_CENTER:String = "center";
		public static const ALIGN_HORIZONTAL_RIGHT:String = "right";
		public static const ALIGN_HORIZONTAL_RANDOM:String = "random";						// Randomly places it
		public static const ALIGN_HORIZONTAL_RANDOM_NO_SEAMS:String = "random-no-seams";	// Randomly places it, but tries not to have visible seams

		public static const ALIGN_VERTICAL_TOP:String = "top";
		public static const ALIGN_VERTICAL_MIDDLE:String = "middle";
		public static const ALIGN_VERTICAL_BOTTOM:String = "bottom";
		public static const ALIGN_VERTICAL_RANDOM:String = "random";						// Randomly places it
		public static const ALIGN_VERTICAL_RANDOM_NO_SEAMS:String = "random-no-seams";		// Randomly places it, but tries not to have visible seams

		// Properties
		protected var _alignHorizontal:String;
		protected var _alignVertical:String;
		protected var _smoothing:Boolean;
		protected var _bitmapScaleX:Number;
		protected var _bitmapScaleY:Number;

		// Instances
		protected var bitmapData:BitmapData;
		protected var bitmap:Bitmap;

		protected var source:BitmapData;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BitmapFillBox(__alignHorizontal:String = "left", __alignVertical:String = "top") {
			super();

			_alignHorizontal = __alignHorizontal;
			_alignVertical = __alignVertical;
			_bitmapScaleX = 1;
			_bitmapScaleY = 1;
			_smoothing = false;
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth():void {
			RenderUtils.addFunction(redraw);
		}

		override protected function redrawHeight():void {
			RenderUtils.addFunction(redraw);
		}

		protected function redraw():void {
			removeBitmap();

			if (Boolean(source) && _width > 0 && _height > 0) {

				var w:Number = Math.round(_width);
				var h:Number = Math.round(_height);

				var i:int, j:int;

				bitmapData = new BitmapData (w, h, true, 0x00000000);
				bitmapData.lock();

				var sourceResized:BitmapData = new BitmapData(Math.round(source.width * _bitmapScaleX), Math.round(source.height * _bitmapScaleY), source.transparent, 0x00000000);
				var mtx:Matrix = new Matrix();
				mtx.scale(sourceResized.width / source.width, sourceResized.height / source.height);
				sourceResized.draw(source, mtx, null, null, null, true);
				sourceResized.lock();

				// Find starting points
				var posX:int;
				var posY:int;

				// TODO: use beginBitmapFill() instead

				switch (_alignHorizontal) {
					case ALIGN_HORIZONTAL_LEFT:
						posX = 0;
						break;
					case ALIGN_HORIZONTAL_CENTER:
						posX = Math.round(w / 2 - sourceResized.width / 2);
						break;
					case ALIGN_HORIZONTAL_RIGHT:
						posX = w - sourceResized.width;
						break;
					case ALIGN_HORIZONTAL_RANDOM:
						posX = Math.round(Math.random() * -sourceResized.width);
						break;
					case ALIGN_HORIZONTAL_RANDOM_NO_SEAMS:
						posX = Math.round(Math.random() * (w - sourceResized.width));
						break;
					default:
						posX = 0;
				}

				switch (_alignVertical) {
					case ALIGN_VERTICAL_TOP:
						posY = 0;
						break;
					case ALIGN_VERTICAL_MIDDLE:
						posY = Math.round(h / 2 - sourceResized.height / 2);
						break;
					case ALIGN_VERTICAL_BOTTOM:
						posY = w - sourceResized.width;
						break;
					case ALIGN_VERTICAL_RANDOM:
						posY = Math.round(Math.random() * -sourceResized.height);
						break;
					case ALIGN_VERTICAL_RANDOM_NO_SEAMS:
						posY = Math.round(Math.random() * (h - sourceResized.height));
						break;
					default:
						posY = 0;
				}

				// Adjust starting position in case it's inside the target image
				while (posX > 0) posX -= sourceResized.width;
				while (posY > 0) posY -= sourceResized.height;

				for (i = posX; i < w; i += sourceResized.width) {
					for (j = posY; j < h; j += sourceResized.height) {
						bitmapData.copyPixels(sourceResized, sourceResized.rect, new Point(i, j));
					}
				}

				sourceResized.dispose();
				sourceResized = null;

				bitmapData.unlock();

				bitmap = new Bitmap(bitmapData);
				addChild(bitmap);

				applySmoothing();
			}
		}

		protected function applySmoothing():void {
			if (Boolean(bitmap)) bitmap.smoothing = _smoothing;
		}

		protected function removeBitmap():void {
			if (Boolean(bitmap)) {
				removeChild(bitmap);
				bitmap.bitmapData = null;
				bitmap = null;
			}

			if (Boolean(bitmapData)) {
				bitmapData.dispose();
				bitmapData = null;
			}
		}

		protected function removeSource():void {
			if (Boolean(source)) {
				source.dispose();
				source = null;
			}
		}


		// ================================================================================================================
		// PUBLIC STATIC INTERFACE ----------------------------------------------------------------------------------------

		public static function getPatternNoise(__width:int = 64, __height:int = 64):BitmapData {
			// Generates a noise bitmap
			var pixels:Vector.<uint> = new Vector.<uint>();
			pixels.length = __width * __height;
			pixels.fixed = true;

			for (var i:int = 0; i < pixels.length; i++) {
				pixels[i] = Math.round(Math.random() * 0xffffff) | 0xff000000;
			}

			var bmp:BitmapData = new BitmapData(__width, __height, false);
			bmp.setVector(bmp.rect, pixels);

			return bmp;
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function setBitmap(__bitmap:Bitmap, __canDisposeOf:Boolean = true):void {
			setBitmapData(__bitmap.bitmapData, __canDisposeOf);

			if (__canDisposeOf) {
				__bitmap.bitmapData = null;
			}
		}

		public function setBitmapData(__bitmapData:BitmapData, __canDisposeOf:Boolean = true):void {
			removeSource();

			source = __bitmapData.clone();

			if (__canDisposeOf) {
				__bitmapData.dispose();
			}

			redraw();
		}

		public function dispose():void {
			removeBitmap();
			removeSource();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get smoothing():Boolean {
			return _smoothing;
		}
		public function set smoothing(__value:Boolean):void {
			if (_smoothing != __value) {
				_smoothing = __value;
				applySmoothing();
			}
		}

		public function get bitmapScaleY():Number {
			return _bitmapScaleY;
		}
		public function set bitmapScaleY(__value:Number):void {
			if (_bitmapScaleY != __value) {
				_bitmapScaleY = __value;
				redraw();
			}
		}

		public function get bitmapScaleX():Number {
			return _bitmapScaleX;
		}
		public function set bitmapScaleX(__value:Number):void {
			if (_bitmapScaleX != __value) {
				_bitmapScaleX = __value;
				redraw();
			}
		}

		public function get alignHorizontal():String {
			return _alignHorizontal;
		}
		public function set alignHorizontal(__value:String):void {
			if (_alignHorizontal != __value || _alignHorizontal == BitmapFillBox.ALIGN_HORIZONTAL_RANDOM || _alignHorizontal == BitmapFillBox.ALIGN_HORIZONTAL_RANDOM_NO_SEAMS) {
				_alignHorizontal = __value;
				redraw();
			}
		}

		public function get alignVertical():String {
			return _alignVertical;
		}
		public function set alignVertical(__value:String):void {
			if (_alignVertical != __value || _alignVertical == BitmapFillBox.ALIGN_VERTICAL_RANDOM || _alignVertical == BitmapFillBox.ALIGN_VERTICAL_RANDOM_NO_SEAMS) {
				_alignVertical = __value;
				redraw();
			}
		}

		public function get bitmapWidth():Number {
			return bitmapData.width;
		}

		public function get bitmapHeight():Number {
			return bitmapData.height;
		}
	}
}
