package com.zehfernando.display {

	import com.zehfernando.display.abstracts.ResizableSprite;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	/**
	 * @author zeh
	 */
	public class BitmapFillBox extends ResizableSprite {
		
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

		// Instances
		protected var bitmapData:BitmapData;
		protected var bitmap:Bitmap;
		
		protected var source:BitmapData;
		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BitmapFillBox(__alignHorizontal:String = "left", __alignVertical:String = "top") {
			super();
			
			_alignHorizontal = __alignHorizontal;
			_alignHorizontal = __alignVertical;
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth(): void {
			redraw();
		}

		override protected function redrawHeight(): void {
			redraw();
		}
		
		protected function redraw(): void {
			removeBitmap();
			
			if (Boolean(source)) {
				
				var w:Number = Math.round(_width);
				var h:Number = Math.round(_height);
				
				var i:int, j:int;
			
				bitmapData = new BitmapData (w, h, true, 0x00000000);
				
				// Find starting points
				var posX:int;
				var posY:int;
				
				switch (_alignHorizontal) {
					case ALIGN_HORIZONTAL_LEFT:
						posX = 0;
						break;
					case ALIGN_HORIZONTAL_CENTER:
						posX = Math.round(w / 2 - source.width / 2);
						break;
					case ALIGN_HORIZONTAL_RIGHT:
						posX = w - source.width;
						break;
					case ALIGN_HORIZONTAL_RANDOM:
						posX = Math.round(Math.random() * -source.width);
						break;
					case ALIGN_HORIZONTAL_RANDOM_NO_SEAMS:
						posX = Math.round(Math.random() * (w - source.width));
						break;
					default:
						posX = 0;
				}
				
				switch (_alignVertical) {
					case ALIGN_VERTICAL_TOP:
						posY = 0;
						break;
					case ALIGN_VERTICAL_MIDDLE:
						posY = Math.round(h / 2 - source.height / 2);
						break;
					case ALIGN_VERTICAL_BOTTOM:
						posY = w - source.width;
						break;
					case ALIGN_VERTICAL_RANDOM:
						posY = Math.round(Math.random() * -source.height);
						break;
					case ALIGN_VERTICAL_RANDOM_NO_SEAMS:
						posY = Math.round(Math.random() * (h - source.height));
						break;
					default:
						posY = 0;
				}
				
				// Adjust starting position in case it's inside the target image
				while (posX > 0) posX -= source.width;
				while (posY > 0) posY -= source.height;

				for (i = posX; i < w; i += source.width) {
					for (j = posY; j < h; j += source.height) {
						bitmapData.copyPixels(source, source.rect, new Point(i, j));
					}
				}
			
				bitmap = new Bitmap(bitmapData);
				addChild(bitmap);
			}
		}
		
		protected function removeBitmap(): void {
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
		
		protected function removeSource(): void {
			if (Boolean(source)) {
				source.dispose();
				source = null;
			}
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
		
		public function dispose(): void {
			removeBitmap();
			removeSource();
		}
	}
}
